UPDATE land_rates
SET    weight = sub.weight
FROM   (
    SELECT gid,
           u.weight - r.weight AS weight
    FROM   univ_density AS u
    JOIN   rest_density AS r
    USING  (gid)
) AS   sub
WHERE  land_rates.gid = sub.gid;
