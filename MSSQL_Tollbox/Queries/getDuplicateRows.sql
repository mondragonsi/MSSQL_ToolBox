SELECT 
    col, 
    COUNT(col)
FROM 
    table_name
GROUP BY 
    col
HAVING 
    COUNT(col) > 1;
