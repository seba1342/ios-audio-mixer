//
//  SoundManager.swift
//  iosHifi
//
//  Created by Sebastien Bailouni on 2/4/22.
//

import Foundation
import AVFAudio

class SoundManagerOld: NSObject, AVAudioPlayerDelegate {
//  static let shared = SoundManager()

  private var audioPlayers: [URL: AVAudioPlayer] = [:]
  private var duplicateAudioPlayers: [AVAudioPlayer] = []

  private override init() {}
  
  func prepare(sound: String) {
    guard let url = Bundle.main.url(forResource: sound, withExtension: ".mp3") else { return }
    guard let player = getAudioPlayer(for: url) else { return }
    
    player.prepareToPlay()
  }
  
  func prepareSounds(sounds: Array<String>) {
    for sound in sounds {
      prepare(sound: sound)
    }
  }

  func play(sound: String, atTime: TimeInterval) {
    guard let url = Bundle.main.url(forResource: sound, withExtension: ".mp3") else { return }
    guard let player = getAudioPlayer(for: url) else { return }
    
    player.numberOfLoops = -1
    player.play(atTime: atTime)
  }
  
  func playSounds(sounds: Array<String>) {
    guard let url = Bundle.main.url(forResource: "met_1", withExtension: ".mp3") else { return }
    let timeOffset = getAudioPlayer(for: url)?.deviceCurrentTime ?? 0 + 0.01
    
    for sound in sounds {
      play(sound: sound, atTime: timeOffset)
    }
  }
  
  func pause(sound: String) {
    guard let url = Bundle.main.url(forResource: sound, withExtension: ".mp3") else { return }
    guard let player = getAudioPlayer(for: url) else { return }
    player.stop()
  }
  
  func pauseSounds(sounds: Array<String>) {
    for sound in sounds {
      pause(sound: sound)
    }
  }

  private func getAudioPlayer(for url: URL) -> AVAudioPlayer? {
    guard let player = audioPlayers[url] else {
      let player = try? AVAudioPlayer(contentsOf: url)
      audioPlayers[url] = player
      return player
    }
  
    return player
  }
  
//  private func getAudioPlayer(forIndex index: Int) -> AVAudioPlayer? {
//    let players = audioPlayers.values
//    let player = players[index]
//
//    return player
//  }
}
