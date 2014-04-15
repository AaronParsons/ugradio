pro parse_alt_az, msg, alt_e, az_e, alt_w, az_w

;  Initialize common variables
;common point2_common

;  Set token strings to be searched for
tokens = ['alt_e=', 'az_e=', 'alt_w=', 'az_w=']
token_len = [6, 5, 6, 5]
pos = make_array(4, /int)

;  find the token string positions
for count = 0, 3 do $
	pos[count] = strpos(msg, tokens[count])

alt_e = ( float(strmid(msg, pos[0] + token_len[0], pos[1] - pos[0] - 1)) ) [0]
az_e = ( float(strmid(msg, pos[1] + token_len[1], pos[2] - pos[1] - 1)) ) [0]
alt_w = ( float(strmid(msg, pos[2] + token_len[2], pos[3] - pos[2] - 1)) ) [0]
az_w = ( float(strmid(msg, pos[3] + token_len[3], strlen(msg) - pos[3] - 1))) [0]

;stop
end
