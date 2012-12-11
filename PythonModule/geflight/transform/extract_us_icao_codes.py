import csv
from wrangler import dw

def get_transform():
    w = dw.DataWrangler()

    # Split data repeatedly on newline  into  rows
    w.add(dw.Split(column=["data"],
                   table=0,
                   status="active",
                   drop=True,
                   result="row",
                   update=False,
                   insert_position="right",
                   row=None,
                   on="\n",
                   before=None,
                   after=None,
                   ignore_between=None,
                   which=1,
                   max=0,
                   positions=None,
                   quote_character=None))

    # Delete empty rows
    w.add(dw.Filter(column=[],
                    table=0,
                    status="active",
                    drop=False,
                    row=dw.Row(column=[],
                 table=0,
                 status="active",
                 drop=False,
                 conditions=[dw.Empty(column=[],
                   table=0,
                   status="active",
                   drop=False,
                   percent_valid=0,
                   num_valid=0)])))

    # Delete  rows where data starts with '==='
    w.add(dw.Filter(column=[],
                    table=0,
                    status="active",
                    drop=False,
                    row=dw.Row(column=[],
                 table=0,
                 status="active",
                 drop=False,
                 conditions=[dw.StartsWith(column=[],
                        table=0,
                        status="active",
                        drop=False,
                        lcol="data",
                        value="===",
                        op_str="starts with")])))

    # Delete  rows where data = '<!-- KBDX was Broadus Airport ...
    w.add(dw.Filter(column=[],
                    table=0,
                    status="active",
                    drop=False,
                    row=dw.Row(column=[],
                 table=0,
                 status="active",
                 drop=False,
                 conditions=[dw.Eq(column=[],
                table=0,
                status="active",
                drop=False,
                lcol="data",
                value="<!-- KBDX was Broadus Airport in Broadus, Montana. Replaced by new airport with FAA ID: 00F -->",
                op_str="=")])))

    # Delete  rows where data contains '<s>''''
    w.add(dw.Filter(column=[],
                    table=0,
                    status="active",
                    drop=False,
                    row=dw.Row(column=[],
                 table=0,
                 status="active",
                 drop=False,
                 conditions=[dw.Contains(column=[],
                      table=0,
                      status="active",
                      drop=False,
                      lcol="data",
                      value="<s>'''",
                      op_str="contains")])))

    # Extract from data between positions 5, 9
    w.add(dw.Extract(column=["data"],
                     table=0,
                     status="active",
                     drop=False,
                     result="column",
                     update=False,
                     insert_position="right",
                     row=None,
                     on=None,
                     before=None,
                     after=None,
                     ignore_between=None,
                     which=1,
                     max=1,
                     positions=[5,9]))

    # Drop data
    w.add(dw.Drop(column=["data"],
                  table=0,
                  status="active",
                  drop=True))

    return w

def apply_transform(in_file, out_file):
    w = get_transform()
    table = w.apply_to_file(in_file)
    writer = csv.writer(open(out_file, "w"))
    writer.writerow(["icao_code"])
    writer.writerows(table.iter_rows())

if __name__=="__main__":
    import os

    in_file = os.path.join(os.environ["DataPath"], "GEFlight", "RawSample", "usairporticaocodes.txt")
    out_file = os.path.join(os.environ["DataPath"], "GEFlight", "ForRelease", "usairporticaocodes.txt")

    apply_transform(in_file, out_file)