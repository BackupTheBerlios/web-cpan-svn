UPDATE consultants2
SET status = (CASE status WHEN 1 THEN 0 ELSE 1 END)
;

