## pd4655_projekt_CONT
## README.md - Konfiguracja i uruchomienie projektu 

### Opis projektu
Projekt służy do analizy plików FASTQC za pomocą FastQC i wyświetlenia wyników przez NGINX

### Kroki konfiguracji i uruchomienia
Utwórz katalog dla projektu:  
`mkdir pd4655-projekt-CONT`  
Wejdz do tego katalogu:   
`cd pd4655-projekt-CONT`    

W katalogu utwórz pliki:  
`touch docker-compose.yml`  
`touch Dockerfile`  
`touch ngnix.conf`    

Utwórz katalog `input` i umieść tam plik FASTQC:  
`mkdir input`  
Przenieś plik FASTQC do katalogu `input`:  
`mv ~/Downloads/SRR8786200_1.fastq.gz input/`    

Zainstaluj narzędzie FASTQC lokalnie (opcjonalnie):  
`sudo apt update`  
`sudo apt install fastqc`    

W pliku `Dockerfile` umieść następującą konfiguraję:  
FROM ubuntu:22.04<br> RUN apt-get update && apt-get install -y \ <br> openjdk-11-jre-headless unzip perl wget && \ <br> wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.12.1.zip && \ <br> unzip fastqc_v0.12.1.zip && \ <br> chmod +x FastQC/fastqc && \ <br> mv FastQC /usr/local/ && \ <br> ln -s /usr/local/FastQC/fastqc /usr/local/bin/fastqc && \ <br> apt-get clean && rm -rf /var/lib/apt/lists/* fastqc_v0.12.1.zip<br> ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64<br> ENV PATH=$JAVA_HOME/bin:$PATH<br> ENV CLASSPATH=/usr/local/FastQC:/usr/local/FastQC/htsjdk.jar:/usr/local/FastQC/jbzip2-0.9.jar:/usr/local/FastQC/cisd-jhdf5.jar<br> ENTRYPOINT ["fastqc"]<br> CMD ["--help"]<br>   
Pobierz obraz Nginx:  
`docker pull nginx:latest`    

W pliku `nginx.conf` umieść nastepującą konfigurację:  
`nano nginx.conf`  
server {<br> listen 80;<br> server_name localhost;<br> root /usr/share/nginx/html;<br> index SRR8786200_1_fastqc.html;<br> location / {<br> try_files $uri $uri/ =404;<br> }<br> }<br>

W pliku `docker-compose.yml` umieść następującą konfigurację:  
version: '3.8'<br> services:<br> fastqc:<br> build:<br> context: .<br> dockerfile: Dockerfile<br> container_name: fastqc_container<br> volumes:<br> - fastqc_results:/results<br> - ./input:/input:ro<br> networks:<br> - fastqc_network<br> environment:<br> JAVA_HOME: /usr/lib/jvm/java-11-openjdk-amd64<br> CLASSPATH: /usr/local/FastQC:/usr/local/FastQC/htsjdk.jar:/usr/local/FastQC/jbzip2-0.9.jar:/usr/local/FastQC/cisd-jhdf5.jar<br> command: /input/SRR8786200_1.fastq.gz -o /results<br> nginx:<br> image: nginx:latest<br> container_name: nginx_container<br> volumes:<br> - fastqc_results:/usr/share/nginx/html:ro<br> - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro<br> ports:<br> - "8080:80"<br> networks:<br> - fastqc_network<br> volumes:<br> fastqc_results:<br> networks:<br> fastqc_network:<br>  

Uruchom projekt:  
`docker compose up --build`     

Sprwdź zawartość katalogu `input`:  
`ls input/`  
Oczekiwane wyniki:  
`SRR8786200_1_fastqc.html`  
`SRR8786200_1_fastqc.zip`    

Analizuj pli FASTQ lokalie (opcjonalnie):  
`fastqc -o input/ input/SRR8786200_1.fastq.gz`    

Upewnij się, że kontener FASTQC działa:  
docker run --rm -v $(pwd)/input:/data staphb/fastqc fastqc /data/SRR8786200_1.fastq.gz`  

Sprawdź serwer Nginx pod adresem:  
[http://localhost:8080](http://localhost:8080)    

### Wyjaśnienie konfiguracji:  
Plik `nginx.conf` definiuje konfigurację serwera Nginx:  
- “listen 80” tzn ze serwer “nasluchuje” na porcie 80
- “Server_name localhost” serwer jest skonfigurowany dla nazwy hosta localhost a wiec bedzie dzialal lokalnie
- “Root /usr/share/nginx/html” a wiec nginx bedzie szukal plikow do obzlsuzenia w katalogu /usr/share/nginx/html
- “Index SRR8786200_1_fastqc.html” plik SRR8786200_1_fastqc.html jest ustawiony jako strona glowna wyswietal sie gdy uzytkownik wchodzi na http://localhost
- Blok location / obsługuje zadania do / i okresla sposob obslugi plikow: - try_files $uri/ =404; $uri: szuka pliku dokladnie odpowiadajacego zadanej sciezce; $uri/: szuka katalogu odpowiadajacego zadanej sciezce; =404: Jesli plik lub katalog nie zozstanie znaleziony zostanie zwrocony blad 404   








