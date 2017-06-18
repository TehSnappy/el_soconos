#!/usr/bin/env python
from soco import SoCo

import soco
import warnings


def get_speakers():
  lst = soco.discover()
  ans = []
  if lst is not None:
    ans = map(lambda x: (x.player_name, x.ip_address, x.volume, x.uid, x.play_mode, x.group.uid, x.group.coordinator.ip_address), lst)
  return ans

def get_favorites():
  with warnings.catch_warnings():
    warnings.simplefilter("ignore")

    my_soco = soco.discovery.any_soco()
    ans = []
    if my_soco is not None:
      lst = my_soco.get_sonos_favorites(0, 20)

      if lst is not None:
        ans = map(lambda x: (x['title'], x['uri'], x['meta']), lst['favorites'])

    return ans

def get_groups():
  my_soco = soco.discovery.any_soco()
  ans = []
  if my_soco is not None:
    lst = my_soco.all_groups

    if lst is not None:
      ans = map(lambda x: (x.uid, x.coordinator.ip_address), lst)

  return ans
  
def get_playlists():
  ans = []
  my_soco = soco.discovery.any_soco()
  if my_soco is not None:
    library = soco.music_library.MusicLibrary(my_soco)
    if library is not None:
      lst = library.get_music_library_information('sonos_playlists', complete_result=True)
      m_lst = library.get_music_library_information('playlists', complete_result=True)

      if lst.total_matches is not 0:
        ans = map(lambda x: (x.title, x.item_id), lst + m_lst)

  return ans
  
def get_artists():
  ans = []
  my_soco = soco.discovery.any_soco()
  if my_soco is not None:
    library = soco.music_library.MusicLibrary(my_soco)
    if library is not None:
      lst = library.get_music_library_information('album_artists', complete_result=True)

      if lst.total_matches is not 0:
        ans = map(lambda x: (x.title, x.item_id), lst)

  return ans
  
