# PHP 8.3:n virallinen FPM-kuva
FROM php:8.3-cli

# Päivitä ja asenna tarvittavat riippuvuudet
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip

# Asenna Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Asenna Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash && \
    mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

# Työskentelyhakemisto
WORKDIR /var/www/sauli

# Kopioi projektin tiedostot konttiin
COPY . .

# Varmista, että var/ ja public/ kansiot ovat olemassa
RUN mkdir -p var public

# Anna oikeudet var/ ja public/ kansioille
RUN chown -R www-data:www-data var public

# Asenna Symfony-projektin riippuvuudet
RUN composer install --no-scripts --no-progress --prefer-dist

# Avaa Symfonyn palvelimen käyttämä portti
EXPOSE 8000

# Käynnistä Symfonyn oma palvelin
CMD ["symfony", "server:start", "--no-tls", "--listen-ip=0.0.0.0", "--no-tls"]
