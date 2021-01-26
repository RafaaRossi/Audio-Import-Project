extends Control

onready var http = $HTTPRequest
onready var stream = $AudioPlayer

func _ready():
#	var file = loadfile("https://jogosdev.afinando.com.br/jogos/Teste/Audio/acerto.wav")
	http.connect("request_completed", self, "request")
	download_audio("https://jogosdev.afinando.com.br/jogos/Teste/Audio/acerto.ogg", "audio.ogg")
	pass

func request(result, response_code, headers, body):
	var audio = loadfile("audio.ogg", body)
	stream.stream = audio
	pass

func download_audio(url : String, file_name : String):
#	http.set_download_file(file_name)
	http.request(url)
	pass

func loadfile(filepath, buffer):
	var bytes = buffer
	# if File is wav
	if filepath.ends_with(".wav"):
		
		var newstream = AudioStreamSample.new()
		#---------------------------
		#parrrrseeeeee!!! :D
		for i in range(0, 100):
			var those4bytes = str(char(bytes[i])+char(bytes[i+1])+char(bytes[i+2])+char(bytes[i+3]))
			
			if those4bytes == "RIFF": 
				print ("RIFF OK at bytes " + str(i) + "-" + str(i+3))
				#RIP bytes 4-7 integer for now
			if those4bytes == "WAVE": 
				print ("WAVE OK at bytes " + str(i) + "-" + str(i+3))

			if those4bytes == "fmt ":
				print ("fmt OK at bytes " + str(i) + "-" + str(i+3))
				
				#get format subchunk size, 4 bytes next to "fmt " are an int32
				var formatsubchunksize = bytes[i+4] + (bytes[i+5] << 8) + (bytes[i+6] << 16) + (bytes[i+7] << 24)
				print ("Format subchunk size: " + str(formatsubchunksize))
				
				#using formatsubchunk index so it's easier to understand what's going on
				var fsc0 = i+8 #fsc0 is byte 8 after start of "fmt "

				#get format code [Bytes 0-1]
				var format_code = bytes[fsc0] + (bytes[fsc0+1] << 8)
				var format_name
				if format_code == 0: format_name = "8_BITS"
				elif format_code == 1: format_name = "16_BITS"
				elif format_code == 2: format_name = "IMA_ADPCM"
				print ("Format: " + str(format_code) + " " + format_name)
				#assign format to our AudioStreamSample
				newstream.format = format_code
				
				#get channel num [Bytes 2-3]
				var channel_num = bytes[fsc0+2] + (bytes[fsc0+3] << 8)
				print ("Number of channels: " + str(channel_num))
				#set our AudioStreamSample to stereo if needed
				if channel_num == 2: newstream.stereo = true
				
				#get sample rate [Bytes 4-7]
				var sample_rate = bytes[fsc0+4] + (bytes[fsc0+5] << 8) + (bytes[fsc0+6] << 16) + (bytes[fsc0+7] << 24)
				print ("Sample rate: " + str(sample_rate))
				#set our AudioStreamSample mixrate
				newstream.mix_rate = sample_rate
				
				#get byte_rate [Bytes 8-11] because we can
				var byte_rate = bytes[fsc0+8] + (bytes[fsc0+9] << 8) + (bytes[fsc0+10] << 16) + (bytes[fsc0+11] << 24)
				print ("Byte rate: " + str(byte_rate))
				
				#same with bits*sample*channel [Bytes 12-13]
				var bits_sample_channel = bytes[fsc0+12] + (bytes[fsc0+13] << 8)
				print ("BitsPerSample * Channel / 8: " + str(bits_sample_channel))
				#aaaand bits per sample [Bytes 14-15]
				var bits_per_sample = bytes[fsc0+14] + (bytes[fsc0+15] << 8)
				print ("Bits per sample: " + str(bits_per_sample))
				
				
			if those4bytes == "data":
				var audio_data_size = bytes[i+4] + (bytes[i+5] << 8) + (bytes[i+6] << 16) + (bytes[i+7] << 24)
				print ("Audio data/stream size is " + str(audio_data_size) + " bytes")

				var data_entry_point = (i+8)
				print ("Audio data starts at byte " + str(data_entry_point))
				
				newstream.data = bytes.subarray(data_entry_point, data_entry_point+audio_data_size-1)
				
			# end of parsing
			#---------------------------

		#get samples and set loop end
		var samplenum = newstream.data.size() / 4
		newstream.loop_end = samplenum
		newstream.loop_mode = 1 #chage to 0 or delete this line if you don't want loop, also check out modes 2 and 3 in the docs
		return newstream  #:D

	#if file is ogg
	elif filepath.ends_with(".ogg"):
		var newstream = AudioStreamOGGVorbis.new()
		newstream.loop = true #set to false or delet this line if you dont want to loop
		newstream.data = bytes
		return newstream

	else:
		print ("ERROR: Wrong filetype or format")


func _on_Button_button_up():
	stream.play()
	pass # Replace with function body.
