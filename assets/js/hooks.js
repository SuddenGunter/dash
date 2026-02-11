import NotificationsAPI from "./notifications";

let Hooks = {};

// used in timer_live.html.heex
Hooks.Timer = {
    mounted() {
        clearInterval(this.timer);
        if (this.el.dataset.state === "running") {
            timeLeft = this.parseTime(this.el.innerText);
            this.startTimer(timeLeft);
        }
    },

    updated() {
        clearInterval(this.timer);
        if (this.el.dataset.state === "running") {
            timeLeft = this.parseTime(this.el.innerText);
            this.startTimer(timeLeft);
        }
    },

    startTimer(initialTimeLeft) {
        let startTime = Date.now();
        let endTime = startTime + initialTimeLeft * 1000;
        let timeLeft = Math.round((endTime - startTime) / 1000);

        let timeLeftElement = this.el;

        // TODO: better version could be implemented using visibility API
        // https://developer.mozilla.org/en-US/docs/Web/API/Document/visibilitychange_event
        // 1 if tab is active - use setInterval to refresh so that user can actually see timer changes
        // 2 if the tab is inactive - cancel setInterval,  use setInterval for 1m (Chrome will execute it only once per minute anyway)
        // or maybe we don't even need it. If it properly throttles it automatically - why should we bother?
        //  another option
        // 1 if tab is active - use setInterval to refresh so that user can actually see timer changes
        // 2 if tab is inactive - disable it (what about tab preview that some users use?)
        // 3 use setTimeout in serviceWorker to send a notification - it will be reliable
        // 4 need to check on CSRF /XSRF in service workers
        this.timer = setInterval(() => {
            if (timeLeft <= 0) {
                clearInterval(this.timer);
                this.pushEvent("timer_live__completed", {})
                document.title = "Timer completed!";
                NotificationsAPI.Send("⏲️ Timer completed!");
                return;
            }

            timeLeft = Math.round((endTime - Date.now()) / 1000);
            timeLeftElement.innerText = this.formatTime(timeLeft);
            document.title = `${this.formatTime(timeLeft)}`;
        }, 1000);
    },

    parseTime(timeString) {
        let [hours, minutes, seconds] = timeString.split(":").map(Number);
        return hours * 3600 + minutes * 60 + seconds;
    },

    formatTime(totalSeconds) {
        let hours = Math.floor(totalSeconds / 3600);
        let minutes = Math.floor((totalSeconds % 3600) / 60);
        let seconds = totalSeconds % 60;
        return [hours, minutes, seconds]
            .map(unit => String(unit).padStart(2, "0"))
            .join(":");
    }
};

export default Hooks;