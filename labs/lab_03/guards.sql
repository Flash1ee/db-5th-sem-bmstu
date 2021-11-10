-- По логину донатера вывести список подписок
CREATE OR REPLACE FUNCTION get_subscribes(donator_login text)
    returns table
            (
                id            bigint,
                description   text,
                category_name category_type

            )
as
$$
BEGIN
    RETURN query (
        select distinct content.id, content.description, content.category_name
        from content
                 join donators_content dc on content.id = dc.content_id
                 join donators d on d.id = dc.donators_id
        where d.login = donator_login
        order by content.id
    );
END;
$$ language plpgsql;

select * from get_subscribes('denis57');