# Docker Setup for Geezap

This Docker Compose setup provides a complete containerized environment for the Geezap Laravel application, fully compatible with Portainer.

## Services Included

- **app** - PHP 8.3 FPM application container
- **nginx** - Web server (port 80)
- **mysql** - MySQL 8.0 database (port 3306)
- **redis** - Redis cache & queue backend (port 6379)
- **horizon** - Laravel Horizon queue worker
- **reverb** - Laravel Reverb WebSocket server (port 8080)
- **scheduler** - Laravel task scheduler
- **typesense** - Typesense search engine (port 8108)

## Quick Start

### 1. Environment Setup

```bash
# Copy the example environment file
cp .env.docker .env

# Edit .env and set your values (especially APP_KEY, DB_PASSWORD, etc.)
nano .env

# Generate application key if not set
php artisan key:generate
```

### 2. Build and Start Containers

```bash
# Build images and start all services
docker-compose up -d --build

# View logs
docker-compose logs -f

# View logs for a specific service
docker-compose logs -f app
```

### 3. Initial Setup

```bash
# Run migrations
docker-compose exec app php artisan migrate --force

# Create storage link
docker-compose exec app php artisan storage:link

# Seed database (optional)
docker-compose exec app php artisan db:seed

# Optimize application
docker-compose exec app php artisan optimize
docker-compose exec app php artisan filament:optimize
```

## Useful Commands

### Application Management

```bash
# Restart all services
docker-compose restart

# Stop all services
docker-compose down

# Stop and remove volumes (WARNING: deletes data)
docker-compose down -v

# View running containers
docker-compose ps

# Access application shell
docker-compose exec app sh

# Run artisan commands
docker-compose exec app php artisan <command>

# Run composer commands
docker-compose exec app composer <command>
```

### Database Management

```bash
# Access MySQL console
docker-compose exec mysql mysql -u geezap -p geezap

# Create database backup
docker-compose exec mysql mysqldump -u geezap -p geezap > backup.sql

# Restore database
docker-compose exec -T mysql mysql -u geezap -p geezap < backup.sql
```

### Queue Management

```bash
# View Horizon dashboard
# Access at: http://localhost/horizon

# Restart Horizon
docker-compose restart horizon

# View Horizon logs
docker-compose logs -f horizon
```

### Cache Management

```bash
# Clear application cache
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan route:clear
docker-compose exec app php artisan view:clear

# Optimize application
docker-compose exec app php artisan optimize
```

## Portainer Integration

This Docker Compose setup is fully compatible with Portainer. All services include:

- **Labels**: Each service is labeled with `com.portainer.managed=true` for easy identification
- **Networks**: Single bridge network for inter-service communication
- **Volumes**: Named volumes with descriptive labels
- **Health Checks**: MySQL and Redis include health checks for better monitoring

### Deploying in Portainer

1. Navigate to Portainer UI
2. Go to **Stacks** > **Add Stack**
3. Choose **Git Repository** or **Upload from computer**
4. Paste the docker-compose.yml content or point to your repository
5. Add environment variables in the **Environment variables** section
6. Click **Deploy the stack**

## Environment Variables

Key environment variables you need to set in `.env`:

```env
APP_KEY=                    # Generate with: php artisan key:generate
APP_URL=http://localhost
APP_PORT=80

DB_DATABASE=geezap
DB_USERNAME=geezap
DB_PASSWORD=               # Set a secure password
DB_ROOT_PASSWORD=          # Set a secure root password

REDIS_PASSWORD=            # Optional, set for production

REVERB_APP_ID=geezap
REVERB_APP_KEY=            # Set a secure key
REVERB_APP_SECRET=         # Set a secure secret
REVERB_PORT=8080

TYPESENSE_API_KEY=         # Set a secure API key
TYPESENSE_PORT=8108
```

## Production Considerations

1. **Security**:
   - Change all default passwords
   - Use strong passwords for database and Redis
   - Set `APP_DEBUG=false`
   - Configure proper firewall rules

2. **SSL/HTTPS**:
   - Add a reverse proxy (Traefik, Nginx Proxy Manager)
   - Or modify nginx configuration to include SSL certificates

3. **Backups**:
   - Set up automated database backups
   - Back up volumes regularly
   - Use Laravel Backup package (already installed)

4. **Monitoring**:
   - Use Portainer for container monitoring
   - Monitor logs: `docker-compose logs -f`
   - Set up Laravel Horizon monitoring

5. **Performance**:
   - Adjust PHP-FPM workers in `docker/php/php-fpm.conf`
   - Tune MySQL in `docker/mysql/my.cnf`
   - Configure OPcache in `docker/php/php.ini`

## Troubleshooting

### Permission Issues

```bash
# Fix storage permissions
docker-compose exec app chown -R www-data:www-data /var/www/html/storage
docker-compose exec app chmod -R 775 /var/www/html/storage
```

### Database Connection Issues

```bash
# Check if MySQL is healthy
docker-compose ps mysql

# View MySQL logs
docker-compose logs mysql

# Test connection
docker-compose exec app php artisan migrate:status
```

### Asset Issues

```bash
# Rebuild assets
docker-compose exec app npm run build

# Clear view cache
docker-compose exec app php artisan view:clear
```

### Queue Not Processing

```bash
# Restart Horizon
docker-compose restart horizon

# Check Horizon logs
docker-compose logs -f horizon

# Manually test queue
docker-compose exec app php artisan queue:work --once
```

## Updating

```bash
# Pull latest code
git pull

# Rebuild containers
docker-compose up -d --build

# Run migrations
docker-compose exec app php artisan migrate --force

# Clear and optimize
docker-compose exec app php artisan optimize
docker-compose exec app php artisan filament:optimize
```

## Support

For issues or questions, refer to:
- [Laravel Documentation](https://laravel.com/docs)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Portainer Documentation](https://docs.portainer.io/)
