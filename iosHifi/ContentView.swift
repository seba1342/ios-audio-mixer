//
//  ContentView.swift
//  iosHifi
//
//  Created by Sebastien Bailouni on 2/4/22.
//

import SwiftUI
import AVFoundation


let INSTRUMENTS = [Sound(name:"drum"), Sound(name:"mellotron"), Sound(name:"noise"), Sound(name:"viola")];
let METRONOMES = [Sound(name:"met_1"), Sound(name:"met_2"), Sound(name: "met_3"), Sound(name:"met_4")];
let SOUNDS = INSTRUMENTS;

let urls = SOUNDS.map { SoundURL(name: $0.name, url: Bundle.main.url(forResource: $0.name, withExtension: "mp3")!) }

var soundManager: SoundManager?

struct ContentView: View {
  func onPause() {
    soundManager?.pause();
  }
  
  var body: some View {
    Text("HiFi")
      .padding()
      .onAppear(perform: {
        soundManager = SoundManager(urls: urls)
      })
    
    List(SOUNDS) { sound in
      SoundButton(sound: sound)
    }
    
    Button("Pause", action: onPause)
      .padding()
      
  }
}

struct Sound: Identifiable {
  let id = UUID()
  let name: String
}

struct SoundButton: View {
  var sound: Sound
  
  func onPlay(name: String) {
    soundManager?.play(song: name)
  }

  var body: some View {
    Button("Play \(sound.name)", action: {onPlay(name: sound.name)})
      .padding()
  }
}



struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
