#!/usr/bin/env python3

import requests
import json
import os

def get_weather():
    try:
        # You can get a free API key from openweathermap.org
        # For now, we'll show a placeholder
        # api_key = "YOUR_API_KEY"
        # city = "Your City"
        # url = f"http://api.openweathermap.org/data/2.5/weather?q={city}&appid={api_key}&units=metric"
        
        # Placeholder weather info
        return "🌤️ 22°C - Partly Cloudy"
        
        # Uncomment below when you have an API key:
        # response = requests.get(url, timeout=5)
        # data = response.json()
        # temp = int(data['main']['temp'])
        # desc = data['weather'][0]['description'].title()
        # return f"🌤️ {temp}°C - {desc}"
        
    except Exception as e:
        return ""

if __name__ == "__main__":
    print(get_weather())
