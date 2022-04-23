version: "3.3"
services:
   kanban-ui:
     image: devopseasylearning2021/group-project04:kanban-ui
     expose:
       - 80
     ports:
       - 1190:80
     depends_on:
       - kanban-postgres
     links:
       - kanban-app
     container_name: kanban_ui_app
     hostname:  kanban_ui_app
     restart: always
     networks:
       project-04:
         aliases:
           - kanban-ui
   front-end:
     image: devopseasylearning2021/group-project04:front-end
     environment:
       PORT: 3000         
       USERS_HOST: user    
       CATALOG_HOST: catalog 
       CART_HOST: cart  
       ORDER_HOST: order 
       USERS_PORT: 8083  
       CATALOG_PORT: 8082  
       CART_PORT: 5000  
       ORDER_PORT: 6000  
       JAEGER_AGENT_HOST: jaeger   
       JAEGER_AGENT_PORT: 6832
     container_name: front-end_app
     ports:
       - 1185:3000
     hostname: front-end_app
     cap_add:     
       - NET_BIND_SERVICE
     restart: always
     networks:
       project-04:
         aliases:
           - front-end
   catalog-db:
     image:  devopseasylearning2021/group-project04:catalog-db
     environment:
       MONGO_INITDB_ROOT_USERNAME: mongoadmin      
       MONGO_INITDB_ROOT_PASSWORD: secret       
       MONGO_INITDB_DATABASE: acmefit
     container_name: catalog_db_app
     hostname:  catalog_db_app
     volumes:
       - $PWD/vol1:/data/db /data/configdb
     cap_add:
       - CHOWN
       - SETGID
       - SETUID
     restart: always
     networks:
       project-04:
         aliases:
           - catalog-db
   jaeger:
     image: devopseasylearning2021/group-project04:jaeger
     container_name: jeager_app
     hostname: jeager_app
     expose: 
       - 14268
       - 16686
       - 5778
       - 5775/udp
     ports:
       - 9268:14268
       - 9686:16686
       - 9778:5778
       - 9831:6831/udp
       - 9832:6832/udp
       - 9775:5775/udp
     restart: always
     networks:
       project-04:
         aliases:
           - jaeger
   catalog:
     image: devopseasylearning2021/group-project04:catalog
     ports:
       - 1180:8082
     environment:
       CATALOG_DB_USERNAME: mongoadmin             
       CATALOG_DB_PASSWORD: secret     
       CATALOG_DB_HOST: catalog-db        
       CATALOG_PORT: 8082      
       CATALOG_DB_PORT: 27017           
       CATALOG_VERSION: v1     
       USERS_HOST: user    
       USERS_PORT: 8083  
       JAEGER_AGENT_HOST: jaeger           
       JAEGER_AGENT_PORT: 6831
     depends_on:
       - catalog-db
     container_name: catalog_app
     hostname:  catalog_app
     restart: always
     networks:
       project-04:
         aliases:
           - catalog
   user-redis-db:  
     image: devopseasylearning2021/group-project04:redis
     expose:
       - 6379 
     ports:
       - 1181:6379
     container_name: user_redis_db_app
     hostname: user_redis_db_app
     restart: always
     networks:
       project-04:
         aliases:
           - user-redis-db 
   user-db:
     image: devopseasylearning2021/group-project04:user-db
     tmpfs:
       - /tmp:rw,noexec,nosuid
     environment:
       MONGO_INITDB_ROOT_USERNAME: mongoadmin
       MONGO_INITDB_ROOT_PASSWORD: secret
       MONGO_INITDB_DATABASE: acmefit
     container_name: user_db_app
     hostname: user_db_app
     restart: always
     networks:
       project-04:
         aliases:
           - user-db
   user:
     image: devopseasylearning2021/group-project04:user
     expose:
       - 8083
     ports:
       - 1182:8083
     environment:
       USERS_DB_USERNAME: mongoadmin  
       USERS_DB_PASSWORD: secret         
       USERS_DB_HOST: user-db     
       USERS_DB_PORT: 27017   
       USERS_PORT: 8083    
       REDIS_DB_HOST: user-redis-db        
       REDIS_DB_PORT: 6379      
       REDIS_DB_PASSWORD: secret           
       JAEGER_AGENT_HOST: jaeger      
       JAEGER_AGENT_PORT: 6831
     container_name: user_app
     hostname: user_app
     restart: always
     networks:
       project-04:
         aliases:
           - user
   redis-db:
     #build: 
        #context: /home/duclair/duclair
        #dockerfile: Dockerfile
     image: devopseasylearning2021/group-project04:redis
     ports:
       - 1183:6379
     container_name: redis_db_app
     hostname: redis_db_app
     restart: always
     networks:
       project-04:
         aliases:
           - redis-db
   cart:
     image: devopseasylearning2021/group-project04:cart
     ports:
       - 1184:5000
     depends_on:
       - redis-db
     environment:
       REDIS_HOST: redis-db     
       REDIS_PORT: 6379   
       REDIS_PASSWORD: secret    
       CART_PORT: 5000     
       AUTH_MODE: 1   
       USER_HOST: user 
       USER_PORT: 8083    
       JAEGER_AGENT_HOST: jaeger          
       JAEGER_AGENT_PORT: 6831
     container_name: cart_app
     hostname: cart_app
     restart: always
     networks:
       project-04:
         aliases:
           - cart
   postgres:
     image: devopseasylearning2021/group-project04:postgres
     environment: 
       POSTGRES_PASSWORD: password     
       POSTGRES_USER: postgres  
       POSTGRES_DB: postgres
     ports:
       - 1186:5432
     volumes:
       - $PWD/postgres-data:/var/lib/postgresql/data
     container_name: postgres_app
     hostname: postgres_app
     restart: always
     networks:
       project-04:
         aliases:
           - postgres
   order:
     image: devopseasylearning2021/group-project04:order
     expose:
       - 6000
     ports:
       - 1187:6000
     environment: 
       JAEGER_AGENT_HOST: jaeger  
       JAEGER_AGENT_PORT: 6831     
       ORDER_DB_USERNAME: postgres  
       ORDER_AUTH_DB: postgres  
       ORDER_DB_PASSWORD: password    
       ORDER_DB_HOST: postgres  
       ORDER_DB_PORT: 5432   
       ORDER_PORT: 6000      
       PAYMENT_PORT: 9000 
       PAYMENT_HOST: payment   
       AUTH_MODE: 1    
       USER_PORT: 8083  
       USER_HOST: user
     container_name: order_app
     hostname: order_app
     restart: always
     networks:
       project-04:
         aliases:
          - order
   payment:
     image: devopseasylearning2021/group-project04:payment
     ports:
       - 1188:9000
     environment:
       JAEGER_AGENT_HOST: jaeger
       JAEGER_AGENT_PORT: 6832        
       PAYMENT_PORT: 9000     
       USERS_HOST: user  
       USERS_PORT: 8083
     container_name: payment_app
     hostname: payment_app
     restart: always
     networks:
       project-04:
         aliases:
           - payment
   kanban-postgres:
     image: devopseasylearning2021/group-project04:kanban-postgres
     ports:
       - 1189:5432
     environment:
       POSTGRES_DB: kanban
       POSTGRES_USER: kanban
       POSTGRES_PASSWORD: kanban
     volumes:
       - $PWD/kanban-data:/var/lib/postgresql/data
     container_name: kanban_postgres_app
     hostname: kanban_postgres_app
     restart: always
     networks:
       project-04:
         aliases:
           - kanban-postgres
        
   kanban-app:
     image: devopseasylearning2021/group-project04:kanban-app
     expose:
       - 8000
     ports:
       - 9203:8000
     environment:
       DB_SERVER: kanban-postgres 
       POSTGRES_DB: kanban 
       POSTGRES_USER: kanban 
       POSTGRES_PASSWORD: kanban
     depends_on:
       - kanban-postgres
     links:
       - kanban-postgres
     container_name: kanban_app_app
     hostname: kanban_app_app
     restart: always
     networks:
       project-04:
         aliases:
           - kanban-app
                 
volumes:
   postgres-data:
   kanban-data:
   vol1:
networks:
   project-04:    

   
