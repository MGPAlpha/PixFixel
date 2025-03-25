class_name FourierTools
	
static func get_2d_fft(image: Image) -> Array[Image]:
	var pix_array = []
	for i in image.get_height():
		var row = []
		for j in image.get_width():
			var pix = image.get_pixel(j, i)
			row.append((pix.r + pix.g + pix.b)/3)
		pix_array.append(row)

	var fft_rows = []
	for i in pix_array.size():
		var fft_row = FFT.fft(pix_array[i])
		fft_rows.append(fft_row)
		
	var fft_rows_transposed = []
	for i in fft_rows[0].size():
		var row = []
		for j in fft_rows.size():
			row.append(fft_rows[j][i])
		fft_rows_transposed.append(row)

	var fft_cols_transposed = []
	for i in fft_rows_transposed.size():
		var fft_col = FFT.fft(fft_rows_transposed[i])
		fft_cols_transposed.append(fft_col)
		
	var fft_cols = []
	for i in fft_cols_transposed[0].size():
		var row = []
		for j in fft_cols_transposed.size():
			row.append(fft_cols_transposed[j][i])
		fft_cols.append(row)

	var amplitudes = []
	var phases = []
	for i in fft_cols.size():
		var real_row = FFT.reals(fft_cols[i])
		var imaginary_row = FFT.imags(fft_cols[i])
		var amp_row = []
		var phase_row = []
		
		for j in real_row.size():
			amp_row.append(sqrt(pow(real_row[j], 2) + pow(imaginary_row[j], 2)))
			phase_row.append(atan2(imaginary_row[j], real_row[j]) / (2*PI) + .5)
		
		amplitudes.append(amp_row)
		phases.append(phase_row)
		
	# Square and Scale
	var max = -1000000000000000
	for i in amplitudes.size():
		for j in amplitudes[i].size():
			var val = amplitudes[i][j]
			val = val*val
			max = max(val, max)
			amplitudes[i][j] = val

	var log_scaling = 1.0/(log(1+max))

	for i in amplitudes.size():
		for j in amplitudes[i].size():
			var val = amplitudes[i][j]
			val = log_scaling * log(1+val)
			amplitudes[i][j] = val

	var periodogram = Image.create_empty(amplitudes[0].size(), amplitudes.size(), false, Image.FORMAT_L8)
	for i in amplitudes.size():
		for j in amplitudes[i].size():
			periodogram.set_pixel(j, i, Color(amplitudes[i][j], amplitudes[i][j], amplitudes[i][j]))
	
	var phasogram = Image.create_empty(phases[0].size(), phases.size(), false, Image.FORMAT_L8)
	for i in phases.size():
		for j in phases[i].size():
			phasogram.set_pixel(j, i, Color(phases[i][j], phases[i][j], phases[i][j]))
	
	return [periodogram, phasogram]
