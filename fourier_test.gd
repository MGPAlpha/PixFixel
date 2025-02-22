#func fourier_test():
	#var pix_array = []
	#for i in image.get_height():
		#var row = []
		#for j in image.get_width():
			#var pix = image.get_pixel(j, i)
			#row.append((pix.r + pix.g + pix.b)/3)
		#pix_array.append(row)
#
	#var fft_rows = []
	#for i in pix_array.size():
		#var fft_row = FFT.fft(pix_array[i])
		#fft_rows.append(fft_row)
		#
	#var fft_rows_transposed = []
	#for i in fft_rows[0].size():
		#var row = []
		#for j in fft_rows.size():
			#row.append(fft_rows[j][i])
		#fft_rows_transposed.append(row)
#
	#var fft_cols_transposed = []
	#for i in fft_rows_transposed.size():
		#var fft_col = FFT.fft(fft_rows_transposed[i])
		#fft_cols_transposed.append(fft_col)
		#
	#var fft_cols = []
	#for i in fft_cols_transposed[0].size():
		#var row = []
		#for j in fft_cols_transposed.size():
			#row.append(fft_cols_transposed[j][i])
		#fft_cols.append(row)
#
	#var reals = []
	#for i in fft_cols.size():
		#var row = FFT.reals(fft_cols[i])
		#reals.append(row)
		#
	## Square and Scale
	#var max = -1000000000000000
	#for i in reals.size():
		#for j in reals[i].size():
			#var val = reals[i][j]
			#val = val*val
			#max = max(val, max)
			#reals[i][j] = val
#
	#var log_scaling = 1.0/(log(1+max))
#
	#for i in reals.size():
		#for j in reals[i].size():
			#var val = reals[i][j]
			#val = log_scaling * log(1+val)
			#reals[i][j] = val
#
	#var periodogram = Image.create_empty(reals[0].size(), reals.size(), false, Image.FORMAT_L8)
	#for i in reals.size():
		#for j in reals[i].size():
			#periodogram.set_pixel(j, i, Color(reals[i][j], reals[i][j], reals[i][j]))
			#
	#image = periodogram
