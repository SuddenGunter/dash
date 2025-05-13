# Dash

Dash is a distributed* timer application. Think of it like a Pomodoro and Google Meet hybrid - a timer that you can share with your friend and have both of you be able to pause/resume it.

## Why?

This is a timer that you can use as a free alternative to Focusmate app, but without a subscription. Just jump on a call with someone you know, share a link to a timer, and you can start your deep focus interval.

## Why "dash"?

Because this app started as a dashboard/launcher for self-hosted apps. Like HomeAssistant, but for web apps. A timer was supposed to be only a single widget on the dashboard.
But when I finished the timer, I decided to focus on other projects, so the dashboard never came to life.

## Where can I see it in action?

You can self-host it. At one point, a fly.io-hosted version of this app existed, but I never shared the link with the community. For a proper public version, I would need some form of auth in the app - you don't want someone guessing the link to your timer and messing with it, right? But, I do not want to implement any type of auth:

- It would probably involve storing at least parts of your personal data on my backend, which leads to me having to implement GDPR banner, privacy policy, cookie banner etc - which would greately degrade the UX ofa  simple shareable timer. Modern web is a mess
- I would need to pay for hosting, and I have no plans to monetise this app with some ad networks stealing your and my data nor implement subscriptions.

This repo contains a simple template for fly.io deployment, which you could use and spin this app in a few minutes, then you can just share the timers with anybody.

## *Note on "distributed"

Don't get me wrong, this is a simple single-node monolith. Yes, timer state is synchronised between all clients and the backend, but it's still relatively simple. At some point, I wanted to experiment with some form of distributed Erlang (Elixir), replicate timers across nodes (so if one goes down, you still have the timer state alive and can continue monitoring it), but then abandoned this idea. But, the term "distributed timer" still lives on.


## Favicon

Open clipart [timer icon](https://openclipart.org/detail/349336/time-timer#google_vignette) used as favicon.
