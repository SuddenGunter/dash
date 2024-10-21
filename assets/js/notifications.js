let NotificationsAPI = {};

NotificationsAPI.RequestPermission = function () {
    console.log("NotificationsAPI: requesting permissions");
    if (Notification.permission === "granted" || Notification.permission === "denied") {
        console.log("NotificationsAPI: permissions already granted or denied");
        return;
    }

    Notification.requestPermission();
}

NotificationsAPI.Enabled = function () {
    if (Notification.permission === "granted") {
        console.log("NotificationsAPI: Enabled: permissions granted");
        return true;
    }

    console.log("NotificationsAPI: Enabled: permissions not granted");
    return false;
}


NotificationsAPI.Send = function (Msg) {
    console.log("NotificationsAPI: Send");
    if (NotificationsAPI.Enabled()) {
        console.log("NotificationsAPI: Send: sending notification");
        const notification = new Notification(Msg);
    }
}

export default NotificationsAPI;