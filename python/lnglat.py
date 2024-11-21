import geopandas as gpd
from shapely.geometry import Point, mapping
import joblib
import pandas as pd

hdongs =  gpd.read_file('data/서울시 상권분석서비스(영역-행정동)/서울시 상권분석서비스(영역-행정동).shp')
# 좌표계 설정 (WGS 84)

hdongs = hdongs.to_crs(epsg=4326)

# 확인할 포인트 (위도, 경도)
lat, lng = 37.5574771, 127.0020518

# Point 객체 생성
p = Point(lng, lat)

# 포인트가 포함된 행정동 찾기
hdongs_2 = hdongs[hdongs.contains(p)]


#### 동이름
# print(hdongs_2.ADSTRD_NM.values[0])

convs =  pd.read_csv('data/convs.csv', index_col=0)


#### 폴리곤 json
polygon = hdongs_2['geometry'].item()
polygon_json = mapping(polygon)
# print({"polygon": polygon_json})

# Point 객체 생성
geometry = [Point(xy) for xy in zip(convs['lng'], convs['lat'])]

# GeoDataFrame 생성
convs_gdf = gpd.GeoDataFrame(convs, geometry=geometry, crs="EPSG:4326")


#### 편의점 수
# print(gpd.sjoin(convs_gdf, hdongs_2, how='inner',  predicate='within').shape[0])



#### 매출예측
meta = pd.read_csv('data/ai_models/meta.csv', index_col=0)

##### 이 부분을 입력받은 값으로 채우세요
test_pops = [meta.loc[:,hdongs_2.ADSTRD_NM.values[0]].iloc[:5]]

loaded_model = joblib.load(f'data/ai_models/lr_model_{hdongs_2.ADSTRD_NM.values[0]}.joblib')

print(loaded_model.predict(test_pops)/ meta.loc[:,hdongs_2.ADSTRD_NM.values[0]].iloc[-1])
