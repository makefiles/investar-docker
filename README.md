# Investar with Docker
> 내용 설명은 어느정도 Ubuntu, Docker 환경을 알고 있다는 가정하에 진행합니다.<br/>
기타 문의 사항은 make.exe@gmail.com 으로 연락 바랍니다.
> 
> [책 표지 출처: Yes24](https://www.yes24.com/Product/Goods/91401258)<br/>
> 

<br/>

## 만든 배경
- 책을 읽고 실습을 해보는 과정에 네이버 증권 웹페이지의 데이터를 스크래핑 하는 부분이 있습니다.
- 스크래핑 데이터를 나의 로컬 DB 에 저장, 향후 증권 데이터를 분석할때 조회하여 사용 할 수 있습니다.
- 매번 웹에서 스크래핑 하는 것은 속도가 느리기 때문에 매일 적은양의 데이터를 DB 에 저장해 놓고, 필요한 날짜 구간을 내 DB 에서 검색하여 그 데이터를 활용하는 것이 합리적입니다.
- 책에서는 웹 스크래핑과 DB 저장을 Windows 환경에서 파이썬 예제 코드로 구현한 부분이 있는데, 개인적으로 Platform 과 무관하게 항상 동작하는 환경으로 만들고 싶었습니다.
- 그래서 책에서의 예제 과정을 Docker 로 구성하고 이를 Platform 과 관계없이 어디든 백그라운드로 실행되도록 만들었습니다.

<br/>
<br/>

## 책 설명
<img src="https://image.yes24.com/goods/91401258/XL" alt="https://image.yes24.com/goods/91401258/XL" width="300px" /> 

### 파이썬 증권 데이터 분석 - 김황후 저
- 증권 데이터 분석을 위해 파이썬을 이용하여, 웹 스크레핑, 트레이딩 전략 코드 구현을 설명합니다.
- 더 낳아가 자동매매까지 할 수 있도록 투자 전략부터 파이썬 언어에 이르기까지 기술적 전반에 걸친 설명을 다루고 있습니다.
- 세세한 기술적인 부분은 각자 따로 공부해야 하지만, 전체적인 그림을 그려보기 위한 참고 서적으로는 매우 훌륭합니다.
- 개인적으로는 딥러닝 파트가 조금 아쉬웠지만, 딥러닝 자체에 대한 요약은 괜찮다고 생각합니다.
- 2019년 출판본이어서 최근 정보와 살짝 맞지 않는 부분이 있으니 참고하시기 바랍니다.

<br/>
<br/>

## 폴더 구조
|  | 설명 |
| --- | --- |
| data/ | Docker 인스턴스 안에 생성되어 외부와 Mount 되는 DB 폴더 |
| init/ | Docker 인스턴스 실행 시 수행되는 DB 테이블 생성 SQL 과 Python 설치 패키지 목록 |
| script/ | 웹 스크래핑과 DB에 데이터를 업데이트하는 Python 코드 |
| Dockerfile | Python Docker 이미지를 만드는 설정 파일 |
| docker-compose.yml | Docker 이미지들을 한번에 구성하는 설정 파일 |

<br/>
<br/>

## 개별 설정

### docker-compose.yml

```yaml
environment:
        ### [CAUTION] DB 접속 정보를 본인 환경에 맞게 변경 ###
                TZ: Asia/Seoul
        MYSQL_HOST: 127.0.0.1
        MYSQL_PORT: 3306
        MYSQL_ROOT_PASSWORD: myPa$$word
        MYSQL_DATABASE: investar
        MYSQL_USER: admin
        MYSQL_PASSWORD: myPa$$word
```

### script/DBUpdater.py

```python
class DBUpdater:
    def __init__(self):
        """생성자: MariaDB 연결 및 종목코드 딕셔너리 생성"""

        """ [CAUTION] DB 접속 정보를 본인 환경에 맞게 변경 """
        self.conn = pymysql.connect(host='127.0.0.1', port=3376, user='admin',
            password='myPa$$word', db='INVESTAR', charset='utf8')

        with self.conn.cursor() as curs:
```

<br/>
<br/>

## 시작 하기 (Ubuntu 20.04)
> 증권 데이터가 한글로 되어 있으므로 한글이 잘 출력되는 우분투 환경을 먼저 구성해야 합니다.<br/>
윈도우 (TODO)
>

### Docker 설치

```bash
# 1. 도커 설치
$ sudo apt update

# 2. 필수 패키지 설치
$ sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release

# 3. Docker 공식 GPG키 추가
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 4. APT 저장소 추가
$ echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Docker CE 설치
$ sudo apt update
$ sudo apt install docker-ce docker-ce-cli containerd.io
$ sudo usermod -aG docker $USER
$ sudo systemctl status docker

# 6. Docker 컴포즈 설치
$ sudo curl -L \ 
"https://github.com/docker/compose/releases/download/1.28.5/dockercompose-$(uname -s)-$(uname -m)" \ 
-o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose

# 7. Permission denied 오류 해결
$ sudo chmod 666 /var/run/docker.sock
```

### Docker 컴포즈 실행
> 기타 실행 옵션은 별도로 찾아보시기 바랍니다.
>

```bash
# 1. 저장소 내려받기
$ git clone git@github.com:makefiles/investar-docker.git

# 2. 이미지 빌드와 컴포즈 시작
$ cd investar-docker
$ sudo docker-compose up --build

# 3. 컴포즈 내리기
$ sudo docker-compose down

# 4. 동작 확인
$ tail -f script/DBUpdater.log
```
