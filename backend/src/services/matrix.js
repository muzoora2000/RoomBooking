const PLATFORM_LABEL = {
  zoom: 'Zoom',
  google_meet: 'Google Meet',
  teams: 'Microsoft Teams',
  other: 'the online platform'
};

export function platformName(platform) {
  return PLATFORM_LABEL[platform] || 'the online platform';
}

export function isRoomAudience(sessionMode, recipientMode, staff) {
  if (staff) return sessionMode !== 'online';
  if (sessionMode === 'physical') return recipientMode === 'physical' || recipientMode === 'hybrid';
  if (sessionMode === 'hybrid') return recipientMode === 'physical' || recipientMode === 'hybrid';
  return false;
}

export function isOnlineAudience(sessionMode, recipientMode, staff) {
  if (staff) return sessionMode !== 'physical';
  if (sessionMode === 'online') return true;
  if (sessionMode === 'hybrid') return true;
  return false;
}

function roomSentence(roomText) {
  return roomText ? `${roomText}.` : 'Room details will be confirmed.';
}

function onlineSentence(platform) {
  return `Online on ${platformName(platform)}.`;
}

export function composeSessionMessage({
  event,
  sessionMode,
  recipientKind = 'student',
  recipientMode = 'physical',
  moduleCode,
  moduleName,
  timeText,
  roomText,
  oldTimeText,
  oldRoomText,
  platform,
  oldPlatform,
  roomUrl,
  joinUrl,
  onlineLinkChanged = false,
  notifyOnlinePhysical = true,
  reminderKind = '1h',
  reason = ''
}) {
  const staff = recipientKind === 'staff';
  const codeName = `${moduleCode} ${moduleName}`.trim();
  const room = isRoomAudience(sessionMode, recipientMode, staff);
  const online = isOnlineAudience(sessionMode, recipientMode, staff);
  const link = room ? roomUrl : online ? joinUrl : joinUrl;

  if (event === 'released') {
    if (!staff && sessionMode === 'physical' && !room) return null;
    if (!staff && sessionMode === 'hybrid' && recipientMode === 'online') return null;
    if (sessionMode === 'physical') {
      return {
        title: `Room released: ${codeName}`,
        message: `Room released for ${codeName} at ${timeText}. Nobody checked in within the grace period, so the room is no longer reserved.`,
        link: roomUrl,
        severity: 'critical',
        audience: 'room',
        canSeeLink: false
      };
    }
    return {
      title: `Room released, join online: ${codeName}`,
      message: `Room released for ${codeName} at ${timeText}. The room is no longer reserved; join the session online on ${platformName(
        platform
      )} from My lectures.${reason ? ` ${reason}` : ''}`,
      link: joinUrl,
      severity: 'critical',
      audience: 'online',
      canSeeLink: true
    };
  }

  const prefix =
    event === 'cancelled'
      ? 'CANCELLED: '
      : event === 'updated'
        ? 'UPDATED: '
        : event === 'reminder'
          ? reminderKind === '10m'
            ? 'Starting soon: '
            : 'Reminder: '
          : '';

  if (!staff && sessionMode === 'physical' && recipientMode === 'online') {
    if (!notifyOnlinePhysical) return null;
    const verb =
      event === 'cancelled'
        ? 'was cancelled'
        : event === 'updated'
          ? `was updated and is still on campus at ${timeText}`
          : `is scheduled on campus at ${timeText}`;
    return {
      title: `${prefix}${codeName} on-campus session`,
      message: `${prefix}An on-campus session for ${codeName} ${verb}. No action is needed from you.`,
      link: joinUrl,
      severity: event === 'cancelled' ? 'critical' : 'info',
      audience: 'lowkey',
      canSeeLink: false
    };
  }

  let body = '';
  if (sessionMode === 'physical') {
    body = `${codeName}: ${timeText}, ${roomSentence(roomText)}`;
  } else if (sessionMode === 'online') {
    body = `${codeName}: ${timeText}, ${onlineSentence(platform)}`;
  } else if (staff || recipientMode === 'physical') {
    body = `${codeName}: ${timeText}, ${roomSentence(roomText)} Online backup on ${platformName(platform)}.`;
  } else if (recipientMode === 'hybrid') {
    body = `${codeName}: ${timeText}, ${roomSentence(roomText)} Join online on ${platformName(platform)}.`;
  } else {
    body = `${codeName}: ${timeText}, ${onlineSentence(platform)}`;
  }

  if (event === 'cancelled') {
    body = `${prefix}${codeName} at ${timeText} was cancelled.`;
    if (sessionMode !== 'online' && room && roomText) body += ` The room was ${roomText}.`;
  } else if (event === 'updated') {
    const changes = [];
    if (oldTimeText && oldTimeText !== timeText) changes.push(`Time changed from ${oldTimeText} to ${timeText}`);
    if (oldRoomText && oldRoomText !== roomText) changes.push(`Room changed from ${oldRoomText} to ${roomText}`);
    if (onlineLinkChanged && (online || staff)) changes.push('The online link changed');
    body = `${prefix}${body}${changes.length ? ` ${changes.join('. ')}.` : ''}`;
  } else if (event === 'reminder') {
    body = `${prefix}${body}`;
  }

  return {
    title: `${prefix}${codeName}`,
    message: body,
    link,
    severity: event === 'cancelled' ? 'critical' : event === 'updated' ? 'warning' : 'info',
    audience: room ? (online ? 'room_online' : 'room') : online ? 'online' : 'lowkey',
    canSeeLink: Boolean(online && (sessionMode === 'online' || sessionMode === 'hybrid'))
  };
}

export function composeDisplacementMessage({ moduleCode, moduleName, timeText, roomText, reason }) {
  return {
    title: `Booking displaced: ${moduleCode} ${moduleName}`,
    message: `Your ${moduleCode} ${moduleName} booking at ${timeText}${roomText ? ` in ${roomText}` : ''} was displaced by a higher-priority booking. ${
      reason || 'A lecturer or administrator replaced it.'
    }`,
    severity: 'critical',
    audience: 'staff',
    canSeeLink: false
  };
}
