FROM ghcr.io/cirruslabs/flutter:stable AS flutter-build
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

FROM nginx:1.27-alpine AS app
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=flutter-build /app/build/web /usr/share/nginx/html
EXPOSE 80
