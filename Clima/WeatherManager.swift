//
//  WeatherManager.swift
//  Clima
//
//  Created by Kyle Jordan on 2/23/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    // Add your API Key
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=&units=imperial"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeatherByCityName(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeatherByCoordinates(lat: Double, lon: Double) {
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJson(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJson(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let weatherModel = WeatherModel(conditionId: decodedData.weather[0].id, cityName: decodedData.name, temperature: decodedData.main.temp)
            return weatherModel
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
