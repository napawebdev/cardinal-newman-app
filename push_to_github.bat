@echo off
echo GitHub Push Script
echo ==================
echo.
echo INSTRUCTIONS:
echo 1. Create a repository on GitHub named: cardinal-newman-app
echo 2. Copy the repository URL from GitHub
echo 3. Replace YOUR_REPOSITORY_URL below with the actual URL
echo 4. Run this script
echo.
echo Current repository URL (CHANGE THIS):
echo https://github.com/YOUR_USERNAME/cardinal-newman-app.git
echo.
set /p repo_url="Enter your GitHub repository URL: "

echo.
echo Adding remote origin...
git remote add origin %repo_url%

echo.
echo Pushing to GitHub...
git branch -M main
git push -u origin main

echo.
echo Done! Check GitHub for your repository.
echo The GitHub Actions build should start automatically.
echo.
pause