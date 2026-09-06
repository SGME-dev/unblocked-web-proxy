extends Control

# Grab references to your UI nodes dynamically
@onready var url_input: LineEdit = $VBoxContainer/UrlInput
@onready var go_button: Button = $VBoxContainer/HBoxContainer/GoButton

# Your live, working Render Cloud URL 
const PROXY_SERVER = "https://unblocked-web-proxy.onrender.com/proxy?url="

func _ready() -> void:
	# Connect UI engine signals using Godot 4 callable syntax
	go_button.pressed.connect(_on_go_pressed)
	url_input.text_submitted.connect(_on_url_submitted)

func _on_go_pressed() -> void:
	process_and_navigate(url_input.text)

func _on_url_submitted(new_text: String) -> void:
	process_and_navigate(new_text)

func process_and_navigate(target_url: String) -> void:
	# Ignore blank inputs
	if target_url.strip_edges() == "":
		return
		
	# Automatically patch missing protocols so your friends don't have to type it
	if not target_url.begins_with("http://") and not target_url.begins_with("https://"):
		target_url = "https://" + target_url

	print("Original Input Target: ", target_url)

	# 1. Turn the clean text URL string into raw bytes
	var url_bytes: PackedByteArray = target_url.to_utf8_buffer()
	
	# 2. Encode to Base64 using Godot's built-in Marshalls utility
	var encrypted_string: String = Marshalls.raw_to_base64(url_bytes)
	
	# 3. Swap standard Base64 characters to make it URL-safe for Python
	encrypted_string = encrypted_string.replace("+", "-").replace("/", "_")

	# 4. Construct the complete deployment string
	var final_destination = PROXY_SERVER + encrypted_string
	print("Redirecting request payload to: ", final_destination)

	# 5. Native execution pass
	# On your laptop, this launches your default browser.
	# On your iPad via GitHub Pages web export, this tells Safari to launch the window.
	OS.shell_open(final_destination)
