#!/usr/bin/env bash
if [ "$TERM" = "linux" ]; then
  # set framebuffer
  /bin/echo -e "
  \e]P016191a
  \e]P1be0004
  \e]P22da01d
  \e]P3a57706
  \e]P42176c7
  \e]P5c61c6f
  \e]P6259286
  \e]P7d2d7cd
  \e]P8444542
  \e]P9d51f17
  \e]PA475b62
  \e]PB536870
  \e]PC708284
  \e]PD5956ba
  \e]PE819090
  \e]PFeaeae8
  "
  # get rid of artifacts
  clear
fi

