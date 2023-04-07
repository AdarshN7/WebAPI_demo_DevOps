FROM mcr.microsoft.com/dotnet/aspnet:3.1 AS base
WORKDIR /app
EXPOSE 5003

ENV ASPNETCORE_URLS=http://+:5003

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:3.1 AS build
WORKDIR /src
COPY ["WebAPI_demo_DevOps.csproj", "./"]
RUN dotnet restore "WebAPI_demo_DevOps.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "WebAPI_demo_DevOps.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "WebAPI_demo_DevOps.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "WebAPI_demo_DevOps.dll"]