import AVFoundation

struct SoundURL {
  let name: String
  let url: URL
}

struct SoundFile {
  let file: AVAudioFile
  let name: String
}

class SoundManager {
  var files: [SoundFile] = []
  var fileBuffers: [AVAudioPCMBuffer] = []
  var engine: AVAudioEngine
  var nodes = [AVAudioPlayerNode]()
  var mixer: AVAudioMixerNode
  var duration: Double = 0
    
  init (urls: [SoundURL] = []) {
    // Load files from URL's
    files = urls.map {
      return SoundFile(file: try! AVAudioFile(forReading: $0.url), name: $0.name)
    }
    
    // Calculate the duration of the sound files
    // Because all our samples are the same length we can just base it off the
    // length of the first sound
    let fileLengthInFrames = AVAudioFrameCount(files.first!.file.length)
    let sampleRate = files.first!.file.fileFormat.sampleRate
    duration =  Double(Double(fileLengthInFrames) / sampleRate) // Divide by the AVSampleRateKey in the recorder settings
    
    // Load audio buffers from audio files
    fileBuffers = files.map {
      let audioFormat = $0.file.processingFormat
      let audioFrameCount = UInt32($0.file.length)
      let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
      
      do {
        try $0.file.read(into: audioFileBuffer!)
      } catch {
        print("init(): Unable to load audio buffers from audio file:", $0.name)
      }
      
      return audioFileBuffer!
    }
    
    // We use an audio mixer to attach all our sounds to.
    // This allows us to input multiple sounds and output only one.
    engine = AVAudioEngine()
    mixer = AVAudioMixerNode()
    
    engine.attach(mixer)
    engine.connect(mixer, to: engine.outputNode, format: nil)

    for _ in files {
        nodes += [AVAudioPlayerNode()]
    }
    
    // Add the sounds to the mixer
    for i in 0...nodes.count - 1 {
      engine.attach(nodes[i])
      engine.connect(nodes[i], to: mixer, format: fileBuffers[i].format)
    }
    
    engine.prepare()
    
    do {
      try engine.start()
    } catch {
      print("init(): Unable to start engine")
    }

    print("Prepared audio")
  }
  
  
  func start() {
    for node in nodes {
      node.play()
    }
  }
  
  func pause() {
    for node in nodes {
      node.stop()
    }
  
    engine.stop()
  }
  
  // MARK: Private methods
  
  func currentTime() -> TimeInterval {
    if(!nodes.first!.isPlaying) {
      return 0
    }
    
    if let nodeTime: AVAudioTime = nodes.first?.lastRenderTime, let playerTime: AVAudioTime = nodes.first?.playerTime(forNodeTime: nodeTime) {
      return (Double(playerTime.sampleTime) / playerTime.sampleRate).truncatingRemainder(dividingBy: duration)
    }
    
    return 0
  }
//
//  private func durationOfNodePlayer(_ file: AVAudioFile) -> TimeInterval {
//
//  }
  
  private func seekTo(player: AVAudioPlayerNode, buffer: AVAudioPCMBuffer, index: Int) {
    if(!engine.isRunning) {
      engine.prepare()
      
      do {
        try engine.start()
      } catch {
        print("seekTo(): Unable to start engine")
      }
    }
    
    player.stop()
    
    print("currentTime:", currentTime())
  
    
    let startSample = floor(currentTime() * nodes[index].outputFormat(forBus: 0).sampleRate)
    let lengthSamples = abs(Double(files[index].file.length) - startSample)
    
    print(startSample, lengthSamples,files[index].file.length)
    
    player.scheduleSegment(files[index].file, startingFrame: AVAudioFramePosition(startSample), frameCount: AVAudioFrameCount(lengthSamples), at: nil, completionHandler: {
      self.nodes[index].scheduleBuffer(self.fileBuffers[index], at: nil, options:.loops, completionHandler: nil)
      player.play()
      print("Playing", self.files[index].name)
    })
    player.play()
    
    print("Playing", files[index].name)
  }
   
  
  func play(song: String) {
    guard let index = files.firstIndex(where: {$0.name == song}) else { return }
    seekTo(player: nodes[index], buffer: fileBuffers[index], index: index)
  }
}
