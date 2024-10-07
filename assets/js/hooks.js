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

    startTimer(initialTime) {
        let timeLeft = initialTime;
        let timeLeftElement = this.el;

        this.timer = setInterval(() => {
            if (timeLeft <= 0) {
                clearInterval(this.timer);
                this.pushEvent("timer_live__completed", {})
                NotificationsAPI.Send("⏲️ Timer completed!");
                return;
            }
            timeLeft -= 1;
            timeLeftElement.innerText = this.formatTime(timeLeft);
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