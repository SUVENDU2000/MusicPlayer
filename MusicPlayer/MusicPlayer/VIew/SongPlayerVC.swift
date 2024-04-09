//
//  SongPlayerVC.swift
//  MusicPlayer
//
//  Created by Suvendu Kumar on 07/04/24.
//

import UIKit

class SongPlayerVC: UIViewController {
    
    lazy var containerView : UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var topDraggerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.layer.cornerRadius = 2.5
        view.clipsToBounds = true
        return view
    }()
    
    
    lazy var songsCoverCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(UINib(nibName: "SongsCoverImageCVC", bundle: nil), forCellWithReuseIdentifier: "SongsCoverImageCVC")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    
    lazy var songNameLbl : UILabel = {
        let lable = UILabel()
        lable.numberOfLines = 1
        lable.textAlignment = .center
        lable.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lable.textColor = .white
        return lable
    }()
    
    lazy var artistNameLbl : UILabel = {
        let lable = UILabel()
        lable.numberOfLines = 1
        lable.textAlignment = .center
        lable.font = UIFont.systemFont(ofSize: 16)
        lable.textColor = .white
        lable.alpha = 0.6
        return lable
    }()
    
    lazy var progressBar : UISlider = {
        let slider = UISlider()
        slider.tintColor = .white
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        slider.addTarget(self, action: #selector(playSongWithSliderValue), for: .valueChanged)
        return slider
    }()
    
    lazy var currentSongDurationLbl : UILabel = {
        let lable = UILabel()
        lable.numberOfLines = 1
        lable.textAlignment = .left
        lable.font = UIFont.systemFont(ofSize: 12)
        lable.text = "00.00"
        lable.textColor = .white
        
        return lable
    }()
    
    lazy var totalSongDurationLbl : UILabel = {
        let lable = UILabel()
        lable.numberOfLines = 1
        lable.textAlignment = .center
        lable.font = UIFont.systemFont(ofSize: 12)
        lable.textColor = .white
        lable.text = "00.00"
        return lable
    }()
    
    lazy var playPauseBtn : UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        button.setBackgroundImage(UIImage(systemName: "pause.circle.fill"), for: .selected)
        button.tintColor = .white
        button.addTarget(self, action: #selector(playPauseSong), for: .touchUpInside)
        return button
    }()
    
    lazy var nextBtn : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        button.tintColor = .white
        button.addTarget(self, action: #selector(changeSong), for: .touchUpInside)
        return button
    }()
    
    lazy var previousBtn : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        button.tintColor = .white
        button.addTarget(self, action: #selector(changeSong), for: .touchUpInside)
        return button
    }()
    
    var defaultHeight : CGFloat = UIScreen.main.bounds.height
    var dismissableHeight : CGFloat = UIScreen.main.bounds.height / 2
    var safeAreaHeight = 0.0
    var sharedPlayer : PlayerManager = PlayerManager()
    var previousIndex: Int = 0
    
    
    var musicList : [Musics] = []
    var selectedMusic : Musics = Musics()
    var position = Int()
    private var updateTimer: Timer?
    let loaderView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupPanGesture()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSongStatusUI), name: Notification.Name.init(NOTIFCATION_NAME.SONG_STARTED_PLAYING), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playBackError), name: Notification.Name.init(NOTIFCATION_NAME.PLAYBACK_ERROR), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(songFinishedPlaying), name: NSNotification.Name.init(NOTIFCATION_NAME.SONG_FINISHED_PLAYING), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(songPausedUI), name: NSNotification.Name.init(NOTIFCATION_NAME.SONG_PAUSED), object: nil)
        
        if let isPlaying = PlayerManager.shared.player?.isPlaying {
            if isPlaying {
                updateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updatePogressUI), userInfo: nil, repeats: true)
            }
        }
        
        setUpLoaderView()
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyGradientColor(accentColor: PlayerManager.shared.currentTrack.accent)

        if (UIScreen.main.bounds.size.height >= 812) {
            // Create a top rounded corner as per screen corener radius
            let maskPath = UIBezierPath(roundedRect: containerView.bounds,
                                        byRoundingCorners: [.topLeft, .topRight],
                                        cornerRadii: CGSize(width: 40.0, height: 40.0))

            let maskLayer = CAShapeLayer()
            maskLayer.path = maskPath.cgPath
            containerView.layer.mask = maskLayer
        }
        
        let indexaPath = IndexPath(item: PlayerManager.shared.currentTrackIndex, section: 0)
        self.songsCoverCV.scrollToItem(at: indexaPath, at: .centeredHorizontally, animated: false)

    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    // Setup Loader view
    func setUpLoaderView() {
        playPauseBtn.addSubview(loaderView)
        
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.centerXAnchor.constraint(equalTo: self.playPauseBtn.centerXAnchor).isActive = true
        loaderView.centerYAnchor.constraint(equalTo: self.playPauseBtn.centerYAnchor).isActive = true
        loaderView.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
    }
    
    // Setup Whole Player screen components
    func setupConstraints() {
        view.addSubview(containerView)
        containerView.addSubview(topDraggerView)
        containerView.addSubview(songsCoverCV)
        containerView.addSubview(songNameLbl)
        containerView.addSubview(artistNameLbl)
        containerView.addSubview(progressBar)
        containerView.addSubview(currentSongDurationLbl)
        containerView.addSubview(totalSongDurationLbl)
        containerView.addSubview(playPauseBtn)
        containerView.addSubview(nextBtn)
        containerView.addSubview(previousBtn)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        topDraggerView.translatesAutoresizingMaskIntoConstraints = false
        songsCoverCV.translatesAutoresizingMaskIntoConstraints = false
        songNameLbl.translatesAutoresizingMaskIntoConstraints = false
        artistNameLbl.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        currentSongDurationLbl.translatesAutoresizingMaskIntoConstraints = false
        totalSongDurationLbl.translatesAutoresizingMaskIntoConstraints = false
        playPauseBtn.translatesAutoresizingMaskIntoConstraints = false
        nextBtn.translatesAutoresizingMaskIntoConstraints = false
        previousBtn.translatesAutoresizingMaskIntoConstraints = false

        
        
        // Set static constraints
        NSLayoutConstraint.activate([
            // set container static constraint (trailing & leading)
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // set topDraggerView constraints
            // Set topDraggerView constraints
            topDraggerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            topDraggerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: (30 + ((UIScreen.main.bounds.size.height >= 812) ? 30 : 0))),
            topDraggerView.widthAnchor.constraint(equalToConstant: 40),
            topDraggerView.heightAnchor.constraint(equalToConstant: 5),
            
            // set tableView constraints
            songsCoverCV.topAnchor.constraint(equalTo: topDraggerView.bottomAnchor, constant: 30),
            songsCoverCV.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            songsCoverCV.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            songsCoverCV.bottomAnchor.constraint(equalTo: songNameLbl.topAnchor, constant: -50),
            
            songNameLbl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            songNameLbl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            songNameLbl.heightAnchor.constraint(equalToConstant: 30),
            songNameLbl.bottomAnchor.constraint(equalTo: artistNameLbl.topAnchor, constant: -5),
            
            artistNameLbl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            artistNameLbl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            artistNameLbl.bottomAnchor.constraint(equalTo: progressBar.topAnchor, constant: -50),
            artistNameLbl.heightAnchor.constraint(equalToConstant: 20),
            
            progressBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            progressBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            progressBar.heightAnchor.constraint(equalToConstant: 15),
            progressBar.bottomAnchor.constraint(equalTo: playPauseBtn.topAnchor, constant: -70),
            
            currentSongDurationLbl.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor, constant: 0),
            currentSongDurationLbl.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 10),
            
            totalSongDurationLbl.trailingAnchor.constraint(equalTo: progressBar.trailingAnchor, constant: 0),
            totalSongDurationLbl.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 10),
            
            playPauseBtn.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            playPauseBtn.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -(30 + ((UIScreen.main.bounds.size.height >= 812) ? 70 : 0))),
            playPauseBtn.heightAnchor.constraint(equalToConstant: 65),
            playPauseBtn.widthAnchor.constraint(equalToConstant: 65),
            
            nextBtn.centerYAnchor.constraint(equalTo: playPauseBtn.centerYAnchor),
            nextBtn.leadingAnchor.constraint(equalTo: playPauseBtn.trailingAnchor, constant: 50),
            nextBtn.heightAnchor.constraint(equalToConstant: 65),
            nextBtn.widthAnchor.constraint(equalToConstant: 65),
            
            previousBtn.centerYAnchor.constraint(equalTo: playPauseBtn.centerYAnchor),
            previousBtn.trailingAnchor.constraint(equalTo: playPauseBtn.leadingAnchor, constant: -50),
            previousBtn.heightAnchor.constraint(equalToConstant: 65),
            previousBtn.widthAnchor.constraint(equalToConstant: 65)
            
        ])
        setupCurrentSongData()
        
    }
    
    // Setup Pan Gesture for drag dissmiss
    func setupPanGesture() {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        panGesture.cancelsTouchesInView = false
        containerView.addGestureRecognizer(panGesture)
    }
    
    // Drag downwards to dismiss player screen gradually. Check if user drag upwards
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        
        // drag value in view
        let translation = gesture.translation(in: view)
        
        // Velocity of dragging, if user speedly drag, dismiss the player screen
        let dragVelocity = gesture.velocity(in: view)

        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                // Only allow dragging downwards
                self.containerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended:
            if dragVelocity.y > 500 {
                dismiss(animated: true)
            } else if translation.y < dismissableHeight {
                UIView.animate(withDuration: 0.3) {
                    self.containerView.transform = .identity
                }
            } else {
                dismiss(animated: true)
            }
        default:
            break
        }
    }

    // Setup current song data in container view
    func setupCurrentSongData() {
        DispatchQueue.main.async {
            self.loaderView.color = colorFromHex(hex: PlayerManager.shared.currentTrack.accent)
            self.songNameLbl.text = PlayerManager.shared.currentTrack.name
            self.artistNameLbl.text = PlayerManager.shared.currentTrack.artist
            if let currentTime = PlayerManager.shared.player?.currentTime, let totalDuration = PlayerManager.shared.player?.duration {
                // Convert seconds to minutes and seconds
                let currentTimeMinutes = Int(currentTime) / 60
                let currentTimeSeconds = Int(currentTime) % 60
                
                let totalDurationMinutes = Int(totalDuration) / 60
                let totalDurationSeconds = Int(totalDuration) % 60
                
                // Display formatted time in labels
                self.currentSongDurationLbl.text = String(format: "%02d:%02d", currentTimeMinutes, currentTimeSeconds)
                self.totalSongDurationLbl.text = String(format: "%02d:%02d", totalDurationMinutes, totalDurationSeconds)

                self.progressBar.value = Float(currentTime)
                self.progressBar.maximumValue = Float(totalDuration)
                
            }
            
            if let isPlaying = PlayerManager.shared.player?.isPlaying {
                self.playPauseBtn.isSelected = isPlaying
            }
            
            self.nextBtn.isEnabled = !(PlayerManager.shared.currentTrackIndex == PlayerManager.shared.musicList.count - 1)
            self.previousBtn.isEnabled = !(PlayerManager.shared.currentTrackIndex == 0)

        }
    }
    
    // Handle Play back error while playing song
    @objc func playBackError() {
        DispatchQueue.main.async {
            self.loaderView.stopAnimating()
            let alert = UIAlertController(title: "Playback Error", message: "This song cant be played.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                self.changeSong(button: self.nextBtn)
            }))
            self.present(alert, animated: true)
        }

    }
    
    // Update UI when song is puased 
    @objc func songPausedUI() {
        DispatchQueue.main.async {
            self.playPauseBtn.isSelected = !self.playPauseBtn.isSelected
        }
    }
    
    // Handle current song finished playing
    @objc func songFinishedPlaying() {
        DispatchQueue.main.async {
            self.playPauseBtn.isSelected = false
        }
    }
    
    // Handle when song started to play
    @objc func updateSongStatusUI() {
        DispatchQueue.main.async {
            self.updateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updatePogressUI), userInfo: nil, repeats: true)
            self.loaderView.stopAnimating()
            self.playPauseBtn.isSelected = true
        }
        
    }
    
    // Update slider, current track time secondly using timer
    @objc func updatePogressUI() {
        if let currentTime = PlayerManager.shared.player?.currentTime, let totalDuration = PlayerManager.shared.player?.duration {
            // Convert seconds to minutes and seconds for display
            let currentTimeMinutes = Int(currentTime) / 60
            let currentTimeSeconds = Int(currentTime) % 60

            let totalDurationMinutes = Int(totalDuration) / 60
            let totalDurationSeconds = Int(totalDuration) % 60

            // Display formatted time in labels
            currentSongDurationLbl.text = String(format: "%02d:%02d", currentTimeMinutes, currentTimeSeconds)
            totalSongDurationLbl.text = String(format: "%02d:%02d", totalDurationMinutes, totalDurationSeconds)

            self.progressBar.value = Float(currentTime)
            self.progressBar.maximumValue = Float(totalDuration)
            
        }

    }
    
    // Play/Pause new/current song
    @objc func playPauseSong() {
        hepticFeedBackGenerator()
        if let isPlaying = PlayerManager.shared.player?.isPlaying {
            if isPlaying {
                PlayerManager.shared.player?.pause()
            } else {
                PlayerManager.shared.player?.play()
                updateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updatePogressUI), userInfo: nil, repeats: true)
            }
            playPauseBtn.isSelected = !playPauseBtn.isSelected
            AppDelegate().sharedDelegate().setupCurrentTrackInGlobalView()
        } else {
            self.loaderView.startAnimating()
            PlayerManager.shared.prepareToPlayTrack(PlayerManager.shared.currentTrack.url)
        }
    }
    
    
    // Play next/previous song
    @objc func changeSong(button : UIButton) {
        hepticFeedBackGenerator()
        PlayerManager.shared.player?.stop()
        self.playPauseBtn.isSelected = false
        if button == nextBtn {
            PlayerManager.shared.playNextSong()
        } else {
            PlayerManager.shared.playPreviousSong()
        }
        PlayerManager.shared.player = nil
        updateTimer?.invalidate()
        progressBar.value = 0
        currentSongDurationLbl.text = "00:00"
        totalSongDurationLbl.text = "00:00"
        setupCurrentSongData()
        loaderView.startAnimating()
        AppDelegate().sharedDelegate().setupCurrentTrackInGlobalView()
    }
    
    
    // Play song at slider value
    @objc func playSongWithSliderValue() {
        if let player = PlayerManager.shared.player {
            let newPosition = TimeInterval(progressBar.value)
            player.currentTime = newPosition

            // Play the song from the new position
            player.play()

            // Update UI labels with the new position (convert to minutes and seconds if needed)
            let newPositionMinutes = Int(newPosition) / 60
            let newPositionSeconds = Int(newPosition) % 60
            currentSongDurationLbl.text = String(format: "%02d:%02d", newPositionMinutes, newPositionSeconds)
        }
    }

    
    
}

extension SongPlayerVC : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return musicList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 65, height: UIScreen.main.bounds.width - 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = songsCoverCV.dequeueReusableCell(withReuseIdentifier: "SongsCoverImageCVC", for: indexPath) as! SongsCoverImageCVC
        let listInfo = musicList[indexPath.row]
        let imageUrl = URL(string: "\(APIManager.shared.IMAGE_URL)\(listInfo.cover)")!
        cell.songsCoverImage.getImage(imageURL: imageUrl)
        return cell
    }
    
    // Play and update song data after scrolled
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: songsCoverCV.contentOffset, size: songsCoverCV.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = songsCoverCV.indexPathForItem(at: visiblePoint) else { return }
        let currentIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        
        if currentIndex != previousIndex {
            hepticFeedBackGenerator()
            PlayerManager.shared.currentTrack = musicList[indexPath.row]
            PlayerManager.shared.currentTrackIndex = indexPath.row
            PlayerManager.shared.musicList = musicList
            self.progressBar.value = 0
            setupCurrentSongData()
            PlayerManager.shared.prepareToPlayTrack(PlayerManager.shared.currentTrack.url)
            applyGradientColor(accentColor: PlayerManager.shared.currentTrack.accent)
        }
        previousIndex = currentIndex
        
    }
    
    // Apply gradient color to container view as per song accent color
    func applyGradientColor(accentColor: String) {
        let topColor = colorFromHex(hex: accentColor)
        let bottomColor = UIColor.black.cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.containerView.bounds
        gradientLayer.colors = [topColor.cgColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        // Remove existing gradient layers
        self.containerView.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        // Add the new gradient layer
        self.containerView.layer.insertSublayer(gradientLayer, at: 0)
    }

}
