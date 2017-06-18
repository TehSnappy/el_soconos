#!/usr/bin/env python

from Queue import Empty

import time
import soco
import logging
import pprint
from soco.events import event_listener

def start_subs():
  logging.basicConfig(level=logging.ERROR)
  # pick a device
  device = soco.discover().pop()
  # Subscribe to ZGT events
  sub = device.zoneGroupTopology.subscribe()

  # print out the events as they arise
  t_end = time.time() + 60 * 2
  while time.time() < t_end:
    try:
      event = sub.events.get(timeout=0.5)
      pp = pprint.PrettyPrinter(indent=4)
      pp.pprint(event.variables)

    except Empty:
      pass

    except KeyboardInterrupt:
      print("exiting KeyboardInterrupt")
      sub.unsubscribe()
      event_listener.stop()
      break

    except EOFError:
      print("exiting EOFError")
      sub.unsubscribe()
      event_listener.stop()
      break
  print("exiting loop")
  sub.unsubscribe()

