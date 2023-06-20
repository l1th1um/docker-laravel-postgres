FROM php:8.1-fpm

# Arguments defined in docker-compose.yml
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USER=avs

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \        
    zip  libzip-dev\
    unzip \
    pdftk \
    mariadb-client \
    libnss3 libnss3-dev libgdk-pixbuf2.0-dev libgtk-3-dev libxss-dev\
    libgconf-2-4 libatk1.0-0 libatk-bridge2.0-0 libgdk-pixbuf2.0-0 libgtk-3-0 libgbm-dev libnss3-dev libxss-dev \
    fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-khmeros fonts-kacst fonts-freefont-ttf libxss1 libasound2 \
    wget gnupg libpq-dev

#RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
#    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
#    && apt-get update \
#    && apt-get install -y google-chrome-stable --no-install-recommends

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install the latest npm
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash
RUN apt-get -y install nodejs

RUN npm install -g yarn

# Install PHP extensions
RUN pecl install mongodb
RUN echo "extension=mongodb.so" >> /usr/local/etc/php/conf.d/mongodb.ini

RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql mbstring exif pcntl bcmath gd zip

# Get latest Composer
COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

COPY uploads.ini $PHP_INI_DIR/conf.d/uploads.ini

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $USER_ID -d /home/$USER $USER
RUN mkdir -p /home/$USER/.composer && \
    chown -R $USER:$USER /home/$USER

# Set working directory
WORKDIR /var/www

USER $USER