sudo mv /var/lib/mysql-files/countries.csv .
sudo mv /var/lib/mysql-files/cities.csv .

time python3 translate.py countries.csv countries_translated.csv 1
time python3 translate.py cities.csv cities_translated.csv 1
