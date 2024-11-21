from fastapi import FastAPI
from lnglat import getDongName, getDongPoly, getStoreCount, getStoreSales
import geopandas as gpd
import joblib
import pandas as pd

app = FastAPI()
hdongs =  gpd.read_file('data/서울시 상권분석서비스(영역-행정동)/서울시 상권분석서비스(영역-행정동).shp')
convs =  pd.read_csv('data/convs.csv', index_col=0)

maybe = pd.read_csv('data/ai_models/maybe.csv')

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
async def calculate(teen: float = 1, twen:float = 1, thirty : float = 1, forty : float = 1, fifty : float = 1, lat : float=None, lng: float=None):
    dongName = getDongName(lat, lng, hdongs)

    dongNameReal =  dongName.ADSTRD_NM.values[0]

    pops_raw = maybe[(maybe['기준_년분기_코드'] == 20242) & (maybe['행정동_코드_명'] == dongNameReal)].iloc[:, 4:-1]

    pops = pops_raw * [teen, twen, thirty, forty, fifty]

    # print(pops_raw)
    
    sales = getStoreSales(pops, dongNameReal)[0]

    # print(sales[0])
    return {
                "message" : int(sales),
                "pops" : list(pops_raw.iloc[0, :])
            
            }

@app.get("/people_count")
async def peopleCount(lat : float=None, lng: float=None):
    dongName = getDongName(lat, lng, hdongs)

    dongNameReal =  dongName.ADSTRD_NM.values[0]

    pops_raw = maybe[(maybe['기준_년분기_코드'] == 20242) & (maybe['행정동_코드_명'] == dongNameReal)].iloc[:, 4:-1]
    return {"pops" : list(pops_raw.iloc[0, :])}

@app.get("/other_place")
async def calculate(teen: float = 1, twen:float = 1, thirty : float = 1, forty : float = 1, fifty : float = 1):
    otherPlaceList = []
    for dong in maybe['행정동_코드_명'].unique():
        pops_raw = maybe[(maybe['기준_년분기_코드'] == 20242) & (maybe['행정동_코드_명'] == dong)].iloc[:, 4:-1]
        pops = pops_raw * [teen, twen, thirty, forty, fifty]
        sales = getStoreSales(pops, dong)[0]
        otherPlaceList.append([dong , sales])
    return {'message':otherPlaceList}

@app.get("/all")
async def all(teen: float = 1, twen:float = 1, thirty : float = 1, forty : float = 1, fifty : float = 1, lat : float=None, lng: float=None):
    dong = getDongName(lat, lng, hdongs)
    convs_in_dong = getStoreCount(convs, dong)
    
    dongNameReal =  dong.ADSTRD_NM.values[0]
    
    polygon= getDongPoly(dong)

    pops_raw = maybe[(maybe['기준_년분기_코드'] == 20242) & (maybe['행정동_코드_명'] == dongNameReal)].iloc[:, 4:-1]
    pops = pops_raw * [teen, twen, thirty, forty, fifty]
    
    count = convs_in_dong.shape[0]
    lat_lngs = [(lat, lng) for lat, lng in zip(convs_in_dong['lat'], convs_in_dong['lng'])]
    polygonData=polygon['polygon']['coordinates'][0]
    sales = getStoreSales(pops, dongNameReal)[0]

    return {
        'count' : count, 
        'lat_lngs' : lat_lngs, 
        'polygonData' : polygonData,
        'sales' : sales,
        'pops' : list(pops_raw.iloc[0, :])
        }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host = "127.0.0.1", port = 8000)