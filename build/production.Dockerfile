FROM nginx:1.25.0

LABEL maintainer="Elsiosanches@gmail.com; EdwinBetanc0urt@outlook.com;" \
	description="ADempiere-Vue."


# Init ENV with default values
ENV API_URL="http://localhost:8085" \
	TASK_MANAGER_URL="http://localhost:8080" \
	TZ="America/Caracas"


# Add operative system dependencies
RUN echo "Set Timezone..." && \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
	apt-get update && apt-get install -y tzdata


# Copy src files
COPY build/start.sh .
COPY dist/ /usr/share/nginx/html/


RUN chmod +x *.sh


ENTRYPOINT ["sh" , "start.sh"]
