let NotificationsAPI = {};

NotificationsAPI.RequestPermission = function () {
    if (Notification.permission === "granted") {
        return;
    } else if (Notification.permission !== "denied") {
        Notification.requestPermission();
    }
}

NotificationsAPI.Enabled = function () {
    if (Notification.permission === "granted") {
        return true;
    }

    return false;
}

NotificationsAPI.Denied = function () {
    if (Notification.permission === "denied") {
        return true;
    }

    return false;
}

NotificationsAPI.Send = function (Msg) {
    if (NotificationsAPI.Enabled()) {
        const notification = new Notification(Msg);
    }
}

export default NotificationsAPI;