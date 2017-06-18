#!/usr/bin/env python
from soco import SoCo

import soco
  
def set_volume(ip, vol):
  my_soco = SoCo(ip)
  ans = []
  if my_soco is not None:
    my_soco.play_uri(vol)

  return ans

  
def set_group_volume(ip, vol):
  my_soco = SoCo(ip)
  ans = []
  if my_soco is not None:
    print(soco.services.GroupRenderingControl(my_soco).SetGroupVolume([('InstanceID', 0), ('DesiredVolume', vol)]))


  return ans




def play_uri(ip, uri, meta):
  my_soco = SoCo(ip)
  ans = []
  if my_soco is not None:
    my_soco.play_uri(uri, meta)

  return ans

def play_fav(title, uri, meta, ip):
  my_soco = SoCo(ip)
  ans = []
  if my_soco is not None:
    my_soco.play_uri(uri, meta, title)

  return ans

def stop(ip):
  my_soco = SoCo(ip)
  ans = []
  if my_soco is not None:
    my_soco.stop()

def set_volume(ip, val):
  my_soco = SoCo(ip)
  ans = []
  if my_soco is not None:
    my_soco.volume = val

def add_to_group(spkr_ip, coord_ip):
  my_soco = SoCo(spkr_ip)
  ans = []
  if my_soco is not None:
    my_soco.join(SoCo(coord_ip))

  return ans


def remove_from_group(spkr_ip):
  my_soco = SoCo(spkr_ip)
  ans = []
  if my_soco is not None:
    my_soco.unjoin()

  return ans






