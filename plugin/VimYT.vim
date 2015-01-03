function! Search(search_string) 
	let g:video_ids = []
	let g:video_titles = []

python << EOF
import vim, urllib2
import json

search_string = vim.eval("a:search_string").replace(" ", "+")
URL = "https://gdata.youtube.com/feeds/api/videos?v=2&alt=jsonc&q=" + search_string
TIMEOUT = 10

try:
	response = urllib2.urlopen(URL, None, TIMEOUT).read()
	json_response = json.loads(response)

	videos = json_response.get("data", "").get("items", "")

	for video in videos:
		video_title = video.get("title").replace("'", "")
		vim.command("let video_title = '" + video_title + "'")
		vim.command("call add(g:video_titles, video_title)")

		video_id = video.get("id")
		vim.command("let video_id = '" + video_id + "'")
		vim.command("call add(g:video_ids, video_id)")
	
	vim.command("call Print_Data(\"Search Results for \" . a:search_string, g:video_titles)")

except Exception, e:
	print e

EOF

	nnoremap <CR> :call EnterWasPressed(g:video_ids)<CR>
endfunction

function! Print_Data(header, data) 
	set nonu
	set cursorline
	set ma
	setl syntax=vim
	normal! ggdG

	let i = len(a:data) - 1 
	for datum in reverse(a:data)
		call append(0, i . " '" . datum. "'")
		let i = i - 1
	endfor
	call append(0, "\" " . a:header)

	set noma
	normal! gg
endfunction

function! EnterWasPressed(video_ids) 
	normal! yy
	call PlayVideo(@", a:video_ids) 
endfunction	

function! PlayVideo(video_number, video_ids)
	execute "!vlc https://www.youtube.com/watch?v=" . a:video_ids[a:video_number]
endfunction
