import geopandas as gpd
from shapely.geometry import Point, mapping

import pandas as pd
import joblib

def getDongName(lat, lng, hdongs):
    
    # 좌표계 설정 (WGS 84)
    hdongs = hdongs.to_crs(epsg=4326)

    # 확인할 포인트 (위도, 경도)
    # 입력 !
    # lat, lng = 37.5574771, 127.0020518

    # Point 객체 생성
    p = Point(lng, lat)

    # 포인트가 포함된 행정동 찾기
    hdongs_2 = hdongs[hdongs.contains(p)]

    #### 동이름
    # return(hdongs_2.ADSTRD_NM.values[0])
    return hdongs_2



def getDongPoly(hdongs_2):
    #### 폴리곤 json
    polygon = hdongs_2['geometry'].item()
    polygon_json = mapping(polygon)

    return({"polygon": polygon_json})


def getStoreCount(convs, hdongs_2):

    # Point 객체 생성
    geometry = [Point(xy) for xy in zip(convs['lng'], convs['lat'])]

    # GeoDataFrame 생성
    convs_gdf = gpd.GeoDataFrame(convs, geometry=geometry, crs="EPSG:4326")


    #### 편의점 수
    # !
    return (gpd.sjoin(convs_gdf, hdongs_2, how='inner',  predicate='within'))

def getStoreSales(pops, dongName): 
    loaded_model = joblib.load(f'data/ai_models/lr_model_{dongName}.joblib')
    meta = pd.read_csv('data/ai_models/meta.csv', index_col=0)
    # print(hdongs_2.ADSTRD_NM.values[0])
    return (loaded_model.predict(pops)/ meta.loc[:,dongName].iloc[-1])
