## devbox

The system Dockerfile builds the base image which the app Dockerfile is built on top of.

The two images are separated to make use of Docker caching mechanisms.

For example, dotfiles are changed all the time.

https://www.youtube.com/watch?v=bHdur0fmxis
