from fastapi import FastAPI
from lnglat import getDongName, getDongPoly, getStoreCount
import geopandas as gpd

app = FastAPI()

hdongs =  gpd.read_file('data/서울시 상권분석서비스(영역-행정동)/서울시 상권분석서비스(영역-행정동).shp')

# 행정동의 편의점 수, 예상 매출액, 위도 경도로 신촌동인지 안암동인지,
# 행정동의 편의점 수
@app.get("/store_count")
async def storeCount(lat: float=None, lng: float=None):
    dongName = getDongName(lat, lng, hdongs)
    count = getStoreCount(dongName)
    return {"message": count}

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

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host = "127.0.0.1", port = 8000)