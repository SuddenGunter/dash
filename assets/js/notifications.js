let NotificationsAPI = {};

NotificationsAPI.RequestPermission = function () {
    if (Notification.permission === "granted" || Notification.permission === "denied") {
        return;
    }

    Notification.requestPermission();
}

NotificationsAPI.Enabled = function () {
    if (Notification.permission === "granted") {
        return true;
    }

    return false;
}


NotificationsAPI.Send = function (Msg) {
    if (NotificationsAPI.Enabled()) {
        const notification = new Notification(Msg, {
            requireInteraction: true
        });
    }
}

export default NotificationsAPI;