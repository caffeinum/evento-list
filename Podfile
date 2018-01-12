platform :ios, '9.0'

target 'Evento' do
    use_frameworks!

    pod 'SwiftyJSON'
    pod 'BrightFutures'
    pod 'Alamofire', '~> 4.5.0'
    pod 'AlamofireImage', '~> 3.3'
    
    pod 'FacebookCore'
    pod 'FacebookLogin'
    pod 'FacebookShare'

    def testing_pods
        pod 'Quick'
        pod 'Nimble'
    end

    target 'EventoTests' do
        inherit! :search_paths
        testing_pods
    end

    target 'EventoUITests' do
        inherit! :search_paths
        testing_pods
    end

end
