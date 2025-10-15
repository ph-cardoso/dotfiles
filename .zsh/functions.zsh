# Show path in a readable way
path(){
  echo $PATH | tr ':' '\n'
}

# Function to check if 'clip' exists and alias it to 'clip.exe' if not
check_clip() {
  if ! command -v clip &> /dev/null; then
    alias clip='clip.exe'
  fi
}
check_clip
