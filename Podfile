# 15 Brush Cards iOS Game - Podfile
# Run: pod install

platform :ios, '14.0'

target '15BrushCards' do
  # Firebase
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
  pod 'Firebase/Analytics'

  # Optional: Google Sign In
  # pod 'GoogleSignIn'

  # Optional: Apple Sign In (already built into iOS 13+)
  # No pod needed, use AuthenticationServices framework

  # Testing (optional)
  target '15BrushCardsTests' do
    inherit! :search_paths
    pod 'Firebase/Database'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'FIREBASE_ANALYTICS_COLLECTION_DEACTIVATED=1'
      ]
    end
  end
end
