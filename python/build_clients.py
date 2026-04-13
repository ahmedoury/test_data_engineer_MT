import pandas as pd
import numpy as np


def last_feature(
    df: pd.DataFrame,
    col_name: str,
    col_agg: str = "client_id",
    time_column: str = "event_time",
) -> pd.DataFrame:
    """
    This function takes dataframe and send back the latest feature of 'col_name' aggregated by 'col_agg'
    @parameters
        df :: dataframe :: entry dataframe
        col_name :: str:: name of the colum we want to get the las feature
        col_agg:: str :: name of column you will use to aggregate
        time_column :: str :: name of the column which contains time data
    @return
       latest_feature :: dataframe:: dataframe which contain the latest feature of the column

    """
    latest_feature = (
        df[df[col_name].notna()]
        .sort_values(time_column)
        .groupby(col_agg, as_index=False)
        .last()[[col_agg, col_name]]
    )
    return latest_feature


def build_client(events: list[dict]) -> pd.DataFrame:
    """
    This function takes a list of events and return deduplicated clients rows
    where each row contain:
     client_id :: id of the client ,
     created_at :: the first time client has been registrated
     email :: latest email of the client
     country :: latest country where we have seen this client
    @parameters
        events:: a list of events
     @return
        df_clients :: dataframe :: dataframe which contain client information
    """

    df_events = pd.DataFrame(events)
    df_events["event_time"] = pd.to_datetime(
        df_events["event_time"]
    )  # put the string into timestamp type
    df_events_dedup = df_events.drop_duplicates()  # deduplicate perfect doublon
    df_events_dedup = df_events_dedup.sort_values("event_time").drop_duplicates(
        subset=["event_id"], keep="last"
    )  # deduplicate per event_id and keep the most recent

    cols = ["email", "country"]
    df_events_dedup[cols] = df_events_dedup[cols].replace(
        r"^\s*$", np.nan, regex=True
    )  # replace "", " " by nan
    last_email = last_feature(
        df_events_dedup, col_name="email"
    )  # get last email per clients
    last_country = last_feature(
        df_events_dedup, col_name="country"
    )  # get last country per clients
    # get the creation date
    created_at = (
        df_events_dedup[df_events_dedup.event_type.str.lower() == "client_created"]
        .groupby("client_id", as_index=False)["event_time"]
        .min()
        .rename(columns={"event_time": "created_at"})
    )
    df_clients_info = (
        df_events_dedup[["client_id"]]
        .merge(last_email, on="client_id", how="left")
        .merge(created_at, on="client_id", how="left")
        .merge(last_country, on="client_id", how="left")
    )
    df_clients = df_clients_info.drop_duplicates()
    return df_clients
