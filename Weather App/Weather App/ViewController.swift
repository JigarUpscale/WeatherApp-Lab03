//
//  ViewController.swift
//  Weather App
//
//  Created by Jigar Prajapati on 2022-03-31.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var tempLable: UILabel!
    @IBOutlet weak var locationLable: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var conditionLabel: UILabel!
    
   
    @IBOutlet weak var styleImage: UIImageView!
    @IBOutlet weak var getLocationLable: UILabel!
    
    let locationManager = CLLocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchTextField.delegate = self
        locationManager.delegate = self
        
       

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        getWeather(search: textField.text)
        print(textField.text ?? "")
        return true
    }

    @IBAction func onCurrentPress(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        
    }
    @IBAction func onSearchPress(_ sender: UIButton) {
        searchTextField.endEditing(true)
        getWeather(search: searchTextField.text)
        
    }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        print("Got Location")
        
                if let location = locations.last {
                    let latitute = location.coordinate.latitude
                    let longitude = location.coordinate.longitude
                    print("latlang: \(latitute),\(longitude)")
                    getWeather(search: "\(latitute),\(longitude)")
      }
    
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print(error)
        }
    
    private func getWeather(search: String?) {
        guard let search = search else{
            return
        }
        
        // Step 1: Get URL
        let url = getUrl(search: search)
        
        guard let url = url else {
            print("Could not get URL")
            return
        }
        
        // Step 2: Create URLSession
        let session = URLSession.shared
        
        // Step 3: Create task for session
        let dataTask = session.dataTask(with: url) { [self] data, response, error in
            // network call finished
            print("network call complete")
            
            guard error == nil else {
                print("Received error")
                return
            }
            
            guard let data = data else {
                print("No data found")
                return
            }
            
            if let weather = self.pareseJson(data: data) {
                print(weather.location.name)
                print(weather.location.lat)
                print(weather.location.lon)
                print(weather.current.temp_c)
                print(weather.current.condition.text)
                print(weather.current.condition.code)
                
               
                
                
                
                let code = weather.current.condition.code
                
                DispatchQueue.main.async { [self] in
                    self.locationLable.text = weather.location.name
                    self.tempLable.text = "\(weather.current.temp_c)°C"
                    self.conditionLabel.text = "\(weather.current.condition.text)"
                    self.getLocationLable.text = "\(weather.location.localtime)"
                    
                   
                    
                    if(code == 1003){
                        let config = UIImage.SymbolConfiguration(paletteColors: [.white, .orange])
                        self.image.preferredSymbolConfiguration = config
                        self.image.image = UIImage(systemName: "cloud.moon.fill")
                        
                        self.styleImage.layer.cornerRadius = 20
                        self.styleImage.clipsToBounds = true
                        self.styleImage.layer.borderColor = UIColor.cyan.cgColor
                        self.styleImage.layer.borderWidth = 4
                        
                        
                    } else if(code == 1009){
                        let config = UIImage.SymbolConfiguration(paletteColors: [.white, .orange])
                        self.image.preferredSymbolConfiguration = config
                        self.image.image = UIImage(systemName: "cloud.fog.fill")
                        
                        self.styleImage.layer.cornerRadius = 20
                        self.styleImage.clipsToBounds = true
                        self.styleImage.layer.borderColor = UIColor.gray.cgColor
                        self.styleImage.layer.borderWidth = 4

                        
                    } else if(code == 1000){
                        let config = UIImage.SymbolConfiguration(paletteColors: [.orange, .white])
                        self.image.preferredSymbolConfiguration = config
                        self.image.image = UIImage(systemName: "sun.max.fill")
                        
                        self.styleImage.layer.cornerRadius = 20
                        self.styleImage.clipsToBounds = true
                        self.styleImage.layer.borderColor = UIColor.green.cgColor
                        self.styleImage.layer.borderWidth = 4
                        
                        
                    } else if (code == 1183){
                        let config = UIImage.SymbolConfiguration(paletteColors: [.orange, .white])
                        self.image.preferredSymbolConfiguration = config
                        self.image.image = UIImage(systemName: "cloud.drizzle.fill")
                        
                        self.styleImage.layer.cornerRadius = 20
                        self.styleImage.clipsToBounds = true
                        self.styleImage.layer.borderColor = UIColor.yellow.cgColor
                        self.styleImage.layer.borderWidth = 4

                        
                    } else if(code == 1030){
                        let config = UIImage.SymbolConfiguration(paletteColors: [.white, .orange])
                        self.image.preferredSymbolConfiguration = config
                        self.image.image = UIImage(systemName: "cloud.fog.fill")
                        
                        self.styleImage.layer.cornerRadius = 20
                        self.styleImage.clipsToBounds = true
                        self.styleImage.layer.borderColor = UIColor.orange.cgColor
                        self.styleImage.layer.borderWidth = 4
                        
                        
                    } else if(code == 1213){
                        let config = UIImage.SymbolConfiguration(paletteColors: [.white, .orange])
                        self.image.preferredSymbolConfiguration = config
                        self.image.image = UIImage(systemName: "cloud.snow.fill")
                        
                        self.styleImage.layer.cornerRadius = 20
                        self.styleImage.clipsToBounds = true
                        self.styleImage.layer.borderColor = UIColor.white.cgColor
                        self.styleImage.layer.borderWidth = 4
                        
                        
                    } else if(code == 1225){
                        let config = UIImage.SymbolConfiguration(paletteColors: [.white, .orange])
                        self.image.preferredSymbolConfiguration = config
                        self.image.image = UIImage(systemName: "snowflake.circle.fill")
                        
                        self.styleImage.layer.cornerRadius = 20
                        self.styleImage.clipsToBounds = true
                        self.styleImage.layer.borderColor = UIColor.white.cgColor
                        self.styleImage.layer.borderWidth = 4

                    }
                }
                
                
            }
            
        }
        
        // Step 4: Start the task
        dataTask.resume()
    }
    
    private func pareseJson(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        var weatehrResponde: WeatherResponse?
        
        do{
            weatehrResponde = try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            print("Error parsing weather")
            print(error)
        }
        
        return weatehrResponde
    }
    
    private func getUrl(search: String) -> URL? {
        
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "01d90c97b3104cbbaa720544221603"
        
        let url = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(search)"
        return URL(string: url)
    }
}

struct WeatherResponse: Decodable {
    let location: Location
    let current: Weather
}

struct Location: Decodable {
    let name: String
    let lat: Float
    let lon: Float
    let localtime: String
}

struct Weather: Decodable {
    let temp_c: Float
    let condition: WeatherCondition
}

struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}


