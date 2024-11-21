from fastapi import FastAPI
from lnglat import getDongName, getDongPoly, getStoreCount, getStoreSales
import geopandas as gpd
import joblib
import pandas as pd

app = FastAPI()
hdongs =  gpd.read_file('data/서울시 상권분석서비스(영역-행정동)/서울시 상권분석서비스(영역-행정동).shp')
convs =  pd.read_csv('data/convs.csv', index_col=0)

# 행정동의 편의점 수, 예상 매출액, 위도 경도로 신촌동인지 안암동인지,
# 행정동의 편의점 수
@app.get("/store_count")
async def storeCount(lat: float=None, lng: float=None):
    dongName = getDongName(lat, lng, hdongs)
    convs_in_dong = getStoreCount(convs, dongName)
    count = convs_in_dong.shape[0]
    lat_lngs = [(lat, lng) for lat, lng in zip(convs_in_dong['lat'], convs_in_dong['lng'])]
    return {
        "message": count
        }

@app.get("/dong_polygon")
async def storeCount(lat: str=None, lng: str=None):
    lat = float(lat)
    lng = float(lng)
    dongName = getDongName(lat, lng, hdongs)
    polygon= getDongPoly(dongName)
    polygonData=polygon['polygon']['coordinates'][0]
    # print(polygonData)
    return {"message" : polygonData}

@app.get("/dong_name")
async def storeCount(lat: float=None, lng: float=None):
    dongName = getDongName(lat, lng, hdongs)
    dong = dongName.ADSTRD_NM.values[0]
    return {"message": dong}


@app.get("/calculate")
async def calculate(teen: float = None, twen:float = None, thrity : float = None, forty : float = None, fifty : float = None, lat : float=None, lng: float=None):
    dongName = getDongName(lat, lng, hdongs)

    pops = [[teen, twen, thrity, forty, fifty]]
    
    sales = getStoreSales(pops, dongName)[0]

    # print(sales[0])
    return {"message" : round(sales, 3)}

@app.get("/all")
async def all(teen: float = None, twen:float = None, thrity : float = None, forty : float = None, fifty : float = None, lat : float=None, lng: float=None):
    dong = getDongName(lat, lng, hdongs)
    convs_in_dong = getStoreCount(convs, dong)
    
    polygon= getDongPoly(dong)
    pops = [[teen, twen, thrity, forty, fifty]]
    
    count = convs_in_dong.shape[0]
    lat_lngs = [(lat, lng) for lat, lng in zip(convs_in_dong['lat'], convs_in_dong['lng'])]
    polygonData=polygon['polygon']['coordinates'][0]
    sales = getStoreSales(pops, dong)[0]

    return {
        'count' : count, 
        'lat_lngs' : lat_lngs, 
        'polygonData' : polygonData,
        'sales' : sales
        }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host = "127.0.0.1", port = 8000)