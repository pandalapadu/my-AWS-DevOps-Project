FROM nginx:1.24.0
RUN rm -rf /usr/share/nginx/html/*
RUN rm -rf /etc/nginx/nginx.conf
#we have observed that conf.d have conflict with nginx.conf file
RUN rm -rf /etc/nginx/conf.d/default.conf
COPY static/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf