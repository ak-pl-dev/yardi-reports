//vista

//Notes

Copyright (c) 2005 by Yardi Systems

  NAME        

                               rs_modified_comm_Lease_Statement.SSRS.txt

 

  DESCRIPTION 

                                Lease Statement

               

  PLATFORM    

                                SQL_Server

                               

  DEPENDENCIES 

                                Files - rx_Comm_Lease_Statement.rdlc

               

  NOTES         

  

  MODIFIED     

                                04/21/2005 - Created

                                03/22/2006 - PI-MNM - Put lease status logic using commtenstatus view.

                                04/20/2006 - TR#71916

                                04/25/2006 - TR#71916 - TR.void condition for reversal changed to tr.suserdefined2 and tr.voider     

                                07/04/2006 - TR#75668 - contact_details view added

                                07/10/2006 - TR#75995 - Join condition modified from 'outer join contact_details co on co.hmycontact = t.hmyperson'

                                                                                To left outer join contact_details co on co.hperson = t.hmyperson'

                                09/07/2006 - TR#77858 - PI - For Considering prepayment in Aging subreport.

                        11/09/2006 - TR#76682 - PI - For Optimization.

                                11/13/2006 - TR#80132we are dropping the contact's second, third and fourth address lines on the lease statement.

                12/15/2006 - TR#82738 - PI -Bill To Customer Changes to Lease and Customer Ledgers/statements.

                02/06/2007 - TR#78646 - PI - Modified to add a message box at the bottom of the report.

                03/12/2007 - TR#83829 - PI -The payable does not need to show up until there is a check to offset it

                08/28/2007 - TR#104576 - Commercial tenant ledger shows checks made out to payables, but not the corresponding payable.

                                09/04/2007 - TR#103232 - Modifying address section

                                10/15/2007 - TR#106047 - Verifying the Report

                                01/15/2008 - TR#109033 - Resolved the issue regarding display of 'all' Receipts from Customer for which Charge is applied to Tenant.

                                01/16/2008 - TR#110432 - Resolved the Issue Regarding Display of '0' prefixed to the 'Description' Field in the Report.

                                01/31/2008 - TR#111342 - To Show Billing role contact instead of primary contact.

                                03/03/2008 - TR#110523 -Statement is showing a payable outside of date range, it should not show and should be included in balance forward.

                                02/06/2008 - TR#117386 Resolved the issues concerned to the "BILL TO CUSTOMER" functionality

                                10/21/2009 - TR#198381 - modified the condition for trans.itype=2

                                10/30/2009 - TR#184828 - Description related modification           

                                12/09/2009 - TR#198293 - Added Show Unit filter and new Unit column on report.

 

//End Notes

 

//Database

SSRS rx_Comm_Lease_Statement.rdlc

//End Database

 

//crystal

cryactive Y

crytree N

cryversion 9

param AsofDt=#Begdate#

param Message=select substring(('#hMessage#'),1,200)

param showreport=#Units#

//end crystal

 

//Title

Modified Commercial Lease Statement

//end title

 

//Version

1.0.002 Date:09.12.2009

//end Version



//Select

declare @asofdt datetime

set @asofdt = #begdate#

select distinct p.hmy                                     phmy

                ,p.scode                                  pscode

                ,p.saddr1                                 propname

           ,dbo.CommLeaseUnits(t.hmyperson,@asofdt)  tsunitcode

                ,t.hmyperson                              thmyperson

                ,t.scode                                  tscode

                ,rtrim(ltrim(isnull(p.scode,''))) + '-' + rtrim(ltrim(isnull(t.scode,'')))                 tAccount

                ,ltrim(case when (isnull(t.sfirstname,'') = '' or isnull(t.sfirstname,'') = ' ') then '' else t.sfirstname end 

                                + case when (isnull(t.sfirstname,'') = '' or isnull(t.sfirstname,'') = ' ') then '' else ' ' end

                                + case when (isnull(t.slastname,'') = '' or isnull(t.slastname,'') = ' ') then '' else t.slastname end) tname,

                case when (ltrim(rtrim(co.fname)) = '' and ltrim(rtrim(co.lname)) = ltrim(rtrim(co.scompanyname))) then ltrim(rtrim(co.lname))

                     when (ltrim(rtrim(co.scompanyname)) = '') then ltrim(rtrim(t.sLastName))

                     else ltrim(rtrim(co.scompanyname)) end                                                                                concompanyname,

                case when (ltrim(rtrim(co.lname)) <> ltrim(rtrim(co.scompanyname))) then co.ssalutation +' '+ltrim(rtrim(co.fname)) + ' ' + ltrim(rtrim(co.lname)) 

                     when (ltrim(rtrim(co.fname)) <> '' and ltrim(rtrim(co.lname)) = ltrim(rtrim(co.scompanyname))) then co.ssalutation +' '+ltrim(rtrim(co.fname)) + ' ' + ltrim(rtrim(co.lname)) 

                     else '' end                                                                                                                      conname,

                isnull(co.addr1,' ')  custaddr1,

                isnull(co.addr2,' ')  custaddr2,

                isnull(co.addr3,' ')  custaddr3,

                isnull(co.addr4,' ')  custaddr4, 

                isnull(co.city,' ')   custcity,

                isnull(co.state,' ')  custstate,

                isnull(co.zip,' ')    custzip,

                case when (isnull(t.saddr1,'') = '' or isnull(t.saddr1,'') = ' ') then isnull(p.scity,'') else isnull(t.scity,'') end

                               + ', '

                               + case when (isnull(t.saddr1,'') = '' or isnull(t.saddr1,'') = ' ') then isnull(p.sstate,'') else isnull(t.sstate,'') end

                                + ' '

                                + case when (isnull(t.saddr1,'') = '' or isnull(t.saddr1,'') = ' ') then isnull(p.szipcode,'') else isnull(t.szipcode,'') end      CityStZip            

                ,psm.psname       vname

                ,psm.psaddr1      vaddr1

                ,psm.psaddr2      vaddr2

                ,psm.psCiStZip    vCityStZip

                from property p

                inner join tenant t on (p.hmy = t.hproperty)

                INNER JOIN CommTenant ct ON t.HMYPERSON = ct.hTenant

                inner join commtenstatus ts on ts.istatus=t.istatus

                left outer join (select ps.hmy pshmy

                                                                ,ps.ucode psucode

                                                                ,case when (isnull(ps.sfirstname,'') = '' or isnull(ps.sfirstname,'') = ' ') then '' else isnull(ps.sfirstname,'') end

                                                                                + case when (isnull(ps.sfirstname,'') = '' or isnull(ps.sfirstname,'') = ' ') then '' else ' ' end

                                                                                + case when (isnull(ps.ulastname,'') = '' or isnull(ps.ulastname,'') = ' ') then '' else isnull(ps.ulastname,'') end

                                                                                psname

                                                                ,isnull(ps.saddr1,'') psaddr1                                                                              

                                                                ,isnull(ps.saddr2,'') psaddr2

                                                                ,case when (isnull(ps.scity,'') = '' or isnull(ps.scity,'') = ' ') then '' else isnull(ps.scity,'') end

                                                                + case when ((isnull(ps.scity,'') <> '' or isnull(ps.scity,'') <> ' ') and (isnull(ps.sstate,'') <> '' or isnull(ps.sstate,'') <> ' ')) then ', ' else '' end

                                                                + case when (isnull(ps.sstate,'') = '' or isnull(ps.sstate,'') = ' ') then '' else isnull(ps.sstate,'') end

                                                                + case when ((isnull(ps.szipcode,'') <> '' or isnull(ps.szipcode,'') <> ' ')) then ' ' else '' end

                                                                + case when (isnull(ps.szipcode,'') = '' or isnull(ps.szipcode,'') = ' ') then '' else isnull(ps.szipcode,'') end psCiStZip

                                                                from      person ps

                                                                where ps.hmy = #vendor# ) psm on (1=1)

                Left Outer join Customer Cu on t.hcustomer = cu.hmyperson

                Left Outer join Contact_Details co         On co.hperson  =

                                                                                                                                (case isnull(t.bBillToCustomer, 0)

                                                                                                                                when 0    then t.hmyperson

                                                                                                                                when -1 then T.hCustomer

                                                                                                                end)

                                                                                                And co.itype =

                                                                                                                                (case isnull(t.bBillToCustomer ,0)

                                                                                                                                when -1  then 478

                                                                                                                                when 0 then 542

                                                                                                                end)

                                                                                                And co.bbilling=1

                where  

                                1 = 1     

                                and isnull(t.bBillToCustomer,0) = 0

                                and t.hmyperson in (select tr.hperson

                                                                from      property p

                                                                                inner join trans tr on (p.hmy = tr.hprop)

                                                                                left outer join detail d on (tr.hmy = d.hinvorrec)

                                                                where   tr.iType IN (6, 7)

                                                                                and tr.sDateOccurred <= dateadd(mm,1,'#endmonth#')- day('#endmonth#')

                                                                                /* and tr.void = case '#Revers#' when 'No' then 0 else tr.void end */

                                                                                and tr.suserdefined2 not in ( case '#Revers#' when 'No' then ':ReverseChg' else '!@#$%^&*()' end) 

                                                                                and tr.voider in(case tr.itype when 6 then 0 when 7 then tr.voider end , case tr.itype when 6 then case '#Revers#' when 'No' then 0 else -1 end when 7 then                tr.voider end)

                                                                                #condition1#

                                                                group by tr.hperson

                                                                having convert(money,'#mindue#') <= case convert(money,'#mindue#')

                                                                                when 0 then 0            

                                                                                else sum(CASE tr.iType WHEN 7 THEN tr.sTotalAmount ELSE -d.sAmount END)

                                                                                end )

                #conditions#

order by p.scode,t.scode

//End Select

 

//Select S1

SELECT
                 phmy
                ,thunit
                ,thmyperson
                ,Tran_Type
                ,trhmy
                , Tran_Date
                , Description       
                ,Sum(Charges - Paymants) Charges
                ,LsUnits
                                                FROM (
                                                                SELECT phmy
                                                                                ,thunit
                                                                                ,thmyperson
                                                                                ,Tran_Type
                                                                                ,trhmy
                                                                                ,Tran_Date
                                                                                ,Description
                                                                                ,sum(Charges) Charges
                                                                                ,sum(Paymants) Paymants
                                                                                ,LsUnits
                                                                FROM (
                                                                                SELECT p.hmy phmy
                                                                                                ,t.hunit thunit
                                                                                                ,t.hmyperson thmyperson
                                                                                                ,'1' Tran_Type
                                                                                                ,NULL trhmy
                                                                                                ,NULL Tran_Date
                                                                                                ,'Balance Forward' Description
                                                                                                ,sum(CASE tr.iType
                                                                                                                                WHEN 7
                                                                                                                                                THEN tr.sTotalAmount
                                                                                                                                WHEN 3
                                                                                                                                                THEN CASE
                                                                                                                                                                                WHEN d.hchkorchg IS NULL
                                                                                                                                                                                                THEN 0
                                                                                                                                                                                ELSE - d.samount
                                                                                                                                                                                END
                                                                                                                                ELSE - d.sAmount
                                                                                                                                END) Charges
                                                                                                ,0 Paymants
                                                                                                ,'' LsUnits
                                                                                FROM property p
                                                                                INNER JOIN tenant t ON (p.hmy = t.hproperty)
                                                                                INNER JOIN commtenstatus ts ON ts.istatus = t.istatus
                                                                                INNER JOIN trans tr ON (t.hMyPerson = tr.hPerson)
                                                                                INNER JOIN acct a ON (tr.hOffsetAcct = a.hMy)
                                                                                LEFT OUTER JOIN detail d ON (d.hinvorrec = tr.hmy)
                                                                                WHERE tr.iType IN (
                                                                                                                3
                                                                                                                ,6
                                                                                                                ,7
                                                                                                                )
                                                                                                AND isnull(t.bBillToCustomer, 0) = 0
                                                                                                AND t.hProperty > 0
                                                                                                AND tr.sDateOccurred < '#begmonth#'
                                                                                                AND tr.void = CASE 'No'
                                                                                                                WHEN 'No'
                                                                                                                                THEN 0
                                                                                                                ELSE tr.void
                                                                                                                END
                                                                                                AND 1=1 #Condition2#
                                                                                GROUP BY p.hmy
                                                                                                ,t.hunit
                                                                                                ,t.hmyperson
                                                                               
                                                                                UNION ALL
                                                                               
                                                                                SELECT p.hmy phmy
                                                                                                ,t.hunit thunit
                                                                                                ,t.hmyperson thmyperson
                                                                                                ,'1' Tran_Type
                                                                                                ,NULL trhmy
                                                                                                ,NULL Tran_Date
                                                                                                ,'Balance Forward' Description
                                                                                                ,0 Charges
                                                                                                ,sum(- tr.stotalamount) Paymants
                                                                                                ,'' LsUnits
                                                                                FROM property p
                                                                                INNER JOIN tenant t ON (p.hmy = t.hproperty)
                                                                                INNER JOIN commtenstatus ts ON ts.istatus = t.istatus
                                                                                INNER JOIN trans tr ON (
                                                                                                                t.hMyPerson = tr.hAccrualAcct
                                                                                                                AND tr.itype = 2
                                                                                                                AND tr.hmy BETWEEN 200000000
                                                                                                                                AND 299999999
                                                                                                                )
                                                                                LEFT OUTER JOIN detail d ON (
                                                                                                                d.hinvorrec = tr.hmy
                                                                                                                AND tr.itype = 6
                                                                                                                )
                                                                                WHERE tr.iType IN (2)
                                                                                                AND isnull(t.bBillToCustomer, 0) = 0
                                                                                                AND t.hProperty > 0
                                                                                                AND tr.sDateOccurred < '#begmonth#'
                                                                                                AND (
                                                                                                                tr.void NOT IN (
                                                                                                                                CASE 'No'
                                                                                                                                                WHEN 'No'
                                                                                                                                                                THEN - 1
                                                                                                                                                WHEN 'Yes'
                                                                                                                                                                THEN - 1
                                                                                                                                                ELSE 0
                                                                                                                                                END
                                                                                                                                )
                                                                                                                OR tr.void NOT IN (
                                                                                                                                CASE 'No'
                                                                                                                                                WHEN 'No'
                                                                                                                                                                THEN - 1
                                                                                                                                                WHEN 'Yes'
                                                                                                                                                                THEN 0
                                                                                                                                                ELSE 0
                                                                                                                                                END
                                                                                                                                )
                                                                                                                )
                                                                                                AND 1=1 #Condition2#
                                                                                GROUP BY p.hmy
                                                                                                ,t.hunit
                                                                                                ,t.hmyperson
                                                                                ) X
                                                                GROUP BY phmy
                                                                                ,thunit
                                                                                ,thmyperson
                                                                                ,Tran_Type
                                                                                ,trhmy
                                                                                ,Tran_Date
                                                                                ,Description
                                                                                ,LsUnits
                                                               
                                                                UNION ALL
                                                               
                                                                SELECT p.hmy phmy
                                                                                ,t.hunit thunit
                                                                                ,t.hmyperson thmyperson
                                                                                ,'1' Tran_Type
                                                                                ,NULL trhmy
                                                                                ,NULL Tran_Date
                                                                                ,'Balance Forward' Description
                                                                                ,0 Charges
                                                                                ,sum(CASE tr.iType
                                                                                                                WHEN 6
                                                                                                                                THEN d.sAmount
                                                                                                                ELSE 0
                                                                                                                END) Paymants
                                                                                ,'' Lsunit
                                                                FROM customer cu
                                                                INNER JOIN trans tr ON cu.hmyperson = tr.hperson
                                                                                AND tr.itype IN (
                                                                                                6
                                                                                                ,7
                                                                                                )
                                                                                AND tr.hmy BETWEEN 600000000
                                                                                                AND 799999999
                                                                LEFT OUTER JOIN detail d ON tr.hMy = d.hInvOrRec
                                                                LEFT OUTER JOIN property p ON d.hProp = p.hMy
                                                                LEFT OUTER JOIN trans trc ON (
                                                                                                d.hChkOrChg = trc.hMy
                                                                                                AND trc.iType = 2
                                                                                                )
                                                                LEFT OUTER JOIN tenant t ON t.hcustomer = cu.hmyperson
                                                                INNER JOIN (
                                                                                SELECT t.scode
                                                                                                ,t.hmyperson
                                                                                                ,t2.hmy
                                                                                FROM tenant t
                                                                                INNER JOIN property p ON p.hmy = t.hproperty
                                                                                INNER JOIN trans t2 ON t2.hperson = t.hmyperson
                                                                                INNER JOIN person per ON per.hmy = t2.hperson
                                                                                                AND per.hmy = t.hmyperson
                                                                                WHERE 1 = 1
                                                                                AND 1=1 #Condition2#
                                                                                ) lease ON lease.hmy = d.hchkorchg
                                                                INNER JOIN Commtenstatus ts ON ts.istatus = t.istatus
                                                                WHERE tr.itype IN (
                                                                                                6
                                                                                                ,7
                                                                                                )
                                                                                AND isnull(p.hlegalentity, 0) = 0
                                                                                AND tr.sDateOccurred < '#begmonth#'                                                                         
                                                                                AND 1=1 #Condition2#
                                                                GROUP BY p.hmy
                                                                                ,t.hunit
                                                                                ,t.hmyperson
                                                                ) y
                                                                Group by            
phmy,thunit,thmyperson,Tran_Type,trhmy,Tran_Date,Description,LsUnits
               
Union All
 
Select
                phmy
                ,thunit         thunit
                ,thmyperson     thmyperson
                ,Tran_Type          Tran_Type          
                ,trhmy                   trhmy
                ,Tran_Date          Tran_Date
                ,case substring(Description,1,1) when '0' then (case substring(Description,1,3) when '0 -'  then  substring(Description,5,len(Description)) else Description end ) else Description end    Description
                ,Charges             Charges
                ,LsUnits       LsUnits
From
(              
Select
                p.hmy               phmy
                ,t.hunit            thunit
                ,t.hmyperson        thmyperson
                ,'2'                Tran_Type
                ,tr.hmy             trhmy
                ,tr.sDateOccurred   Tran_Date
                ,case when (isnull(tr.sUserDefined1,'') <> '' and tr.itype = 6 and Isnumeric(tr.sUserDefined1) = 1) then 'Chk# ' else '' end            
                                +isnull(tr.sUserDefined1,'')
                                + case when (isnull(tr.sUserDefined1,'') = '' or isnull(tr.sNotes,'') = '') then '' else ' - ' end
                                + isnull(tr.sNotes,'') Description
                ,sum(CASE tr.iType
                                WHEN 7 THEN tr.sTotalAmount
                                ELSE 0
                                END)  Charges
                ,isnull(CASE '#Units#'
                                                WHEN 'Yes'
                                                                THEN CASE tr.iType
                                                                                                WHEN 7
                                                                                                                THEN (
                                                                                                                                                isnull(unit.Units,'')
                                                                                                                                                )
                                                                                                ELSE ''
                                                                                                END
                                                ELSE ''
                                                END,'') LsUnits
From     property p
                inner join tenant t on (p.hmy = t.hproperty)
                inner join commtenstatus ts on ts.istatus=t.istatus
                inner join trans tr on (t.hMyPerson = tr.hPerson)
                inner join acct a on (tr.hOffsetAcct = a.hMy)
                left outer join detail d on (d.hinvorrec = tr.hmy and tr.itype = 6)
 
                LEFT JOIN (
                SELECT tr1.HMY
                                ,STUFF((
                                                                SELECT DISTINCT ',' + replace(CASE
                                                                                                                WHEN isnull(cr.hUnit, 0) > 0
                                                                                                                                THEN u1.SCODE
                                                                                                                ELSE u.SCODE
                                                                                                                END, ' ', '')
                                                                FROM trans tr
                                                                LEFT JOIN CAMCHARG ch ON tr.HMY = ch.HPOSTREF
                                                                LEFT JOIN camrule cr ON ch.HCAMRULE = cr.HMY
                                                                LEFT JOIN CommSchedule cs ON cr.hSchedule = cs.hmy
                                                                LEFT JOIN unitxref ux ON cs.hAmendment = ux.hAmendment
                                                                                AND isnull(ux.bActive, 0) = 0
                                                                LEFT JOIN unit u ON ux.hUnit = u.hmy
                                                                LEFT JOIN unit u1 ON cr.hUnit = u1.hmy
                                                                WHERE tr.hmy = tr1.HMY
                                                                FOR XML PATH('')
                                                                ), 1, 1, '') AS Units
                FROM trans tr1
                ) Unit ON unit.HMY = tr.HMY
 
Where tr.iType IN (6, 7)   
        and isnull(t.bBillToCustomer,0) = 0                                      
                and   t.hProperty > 0
                and   tr.sDateOccurred Between '#begmonth#' AND dateadd(mm,1,'#endmonth#')- day('#endmonth#')
                /* and tr.void = case '#Revers#' when 'No' then 0 else tr.void end  */
                and isnull(tr.suserdefined2,' ') not in ( case '#Revers#' when 'No' then ':ReverseChg' else '!@#$%^&*()' end) 
                and tr.voider in(case tr.itype when 6 then 0 when 7 then tr.voider end , case tr.itype when 6 then case '#Revers#' when 'No' then 0 else -1 end when 7 then       tr.voider end)
                and (tr.void not in(case '#Revers#' when 'No' then -1  when 'Yes' then -1 else 0 end)   or tr.void not in(case '#Revers#' when 'No' then -1  when 'Yes' then 0 else 0 end)   )
                #conditions#
Group by            
                p.hmy
                ,t.hunit
                ,t.hmyperson
                ,tr.hmy
                ,tr.sDateOccurred
                ,case when (isnull(tr.sUserDefined1,'') <> '' and tr.itype = 6 and Isnumeric(tr.sUserDefined1) = 1) then 'Chk# ' else '' end            

                                +isnull(tr.sUserDefined1,'')

                                + case when (isnull(tr.sUserDefined1,'') = '' or isnull(tr.sNotes,'') = '') then '' else ' - ' end

                                + isnull(tr.sNotes,'')

                ,t.DTLEASEFROM

                ,tr.hunit

                ,tr.iType

                ,unit.Units

 

)A

Union All

/*To get the check Payables only*/

Select

                p.hmy               phmy

                ,t.hunit            thunit

                ,t.hmyperson        thmyperson

                ,'2'                Tran_Type

                ,tr.hmy             trhmy

                ,tr.sDateOccurred   Tran_Date

                ,'Chk# ' + rtrim(ltrim(tr.uRef)) + ' paid out' +

                case when tr.hAccrualAcct <> t.hmyperson then rtrim(t.sCode) else '' end Description

                ,0 Charges

                ,sum(-tr.stotalamount ) Payments

                ,'' LsUnits

From     property p

                inner join tenant t on (p.hmy = t.hproperty)

                inner join commtenstatus ts on ts.istatus=t.istatus

                inner join trans tr on (t.hMyPerson = tr.hAccrualAcct and tr.itype =2 and tr.hmy between 200000000 and 299999999)

Where tr.iType IN (2)   

                and   t.hProperty > 0

                and   tr.sDateOccurred Between '#begmonth#' AND dateadd(mm,1,'#endmonth#')- day('#endmonth#')

                /* and tr.void = case '#Revers#' when 'No' then 0 else tr.void end  */

                /*and isnull(tr.suserdefined2,' ') not in ( case '#Revers#' when 'No' then ':ReverseChg' else '!@#$%^&*()' end) 

                and tr.voider in(case tr.itype when 6 then 0 when 7 then tr.voider end , case tr.itype when 6 then case '#Revers#' when 'No' then 0 else -1 end when 7 then       tr.voider end) */

                and (tr.void not in(case '#Revers#' when 'No' then -1  when 'Yes' then -1 else 0 end)   or tr.void not in(case '#Revers#' when 'No' then -1  when 'Yes' then 0 else 0 end)   )

                #conditions#

Group by            

                p.hmy

                ,t.hunit

                ,t.hmyperson

                ,tr.hmy

                ,tr.sDateOccurred

                ,'Chk# ' + rtrim(ltrim(tr.uRef)) + ' paid out' +

                case when tr.hAccrualAcct <> t.hmyperson then rtrim(t.sCode) else '' end

/*To get the Payables line items for the check */               

Union all

SELECT  p.hmy

                ,t.hunit            thunit

                ,t.hmyperson        thmyperson

                ,'2'                Tran_Type

                ,tr.hmy             trhmy

                ,tr.sDateOccurred   Tran_Date

                ,rtrim(tr.sNotes)  + ' Payable# '  +convert(varchar,tr.hmy-300000000 )  Description

                ,  -tr.samountpaid charges

                , 0   payments

                ,'' LsUnits

From trans tr

                Inner join tenant t   on tr.hPerson = t.hMyPerson 

                inner join commtenstatus ts on ts.istatus=t.istatus

                Inner join Property p on  t.hproperty=p.hmy

Where tr.itype = 3 

                and tr.samountpaid  <> 0 

                and   tr.sDateOccurred Between '#begmonth#' AND dateadd(mm,1,'#endmonth#')- day('#endmonth#')

                #conditions#

 

/*TO GET THE RECORDS FOR WHICH CHARGE IS APPLIED TO TENANT AND PAYMENT IS MADE BY CUSTOMER*/

Union All            

Select

                phmy

                ,thunit         thunit

                ,thmyperson     thmyperson

                ,Tran_Type          Tran_Type          

                ,trhmy                   trhmy

                ,Tran_Date          Tran_Date

                ,case substring(Description,1,1) when '0' then (case substring(Description,1,3) when '0 -'  then  substring(Description,5,len(Description)) else Description end ) else Description end    Description

                ,Charges             Charges

                ,Payments          Payments

                , LsUnits

From

(

Select

                p.hmy               phmy

                ,t.hunit            thunit

                ,t.hmyperson        thmyperson

                ,'2'                Tran_Type

                ,tr.hmy             trhmy

                ,tr.sDateOccurred   Tran_Date

                ,case when (isnull(tr.sUserDefined1,'') <> '' and tr.itype = 6 and Isnumeric(tr.sUserDefined1) = 1) then 'Chk# ' else '' end            

                                +isnull(tr.sUserDefined1,'')

                                + case when (isnull(tr.sUserDefined1,'') = '' or isnull(tr.sNotes,'') = '') then '' else ' - ' end

                                + isnull(tr.sNotes,'') Description

                ,sum(CASE tr.iType

                                WHEN 7 THEN tr.sTotalAmount

                                ELSE 0

                                END)  Charges

                ,sum(CASE tr.iType

                                WHEN 6 THEN d.sAmount

                                ELSE 0

                                END)  Payments

                ,'' LsUnits

FROM

                customer cu inner join  trans tr on cu.hmyperson = tr.hperson and tr.itype in ( 6, 7)  

                left outer join detail d on tr.hMy = d.hInvOrRec  

                left outer join acct a on isnull(d.hAcct, tr.hoffsetacct) = a.hmy  

                left outer join property p on  isnull(d.hProp, tr.hprop) = p.hMy  

                LEFT OUTER JOIN trans trc ON ( d.hChkOrChg = trc.hMy and trc.iType = 2 )  

                left outer join tenant t on t.hcustomer =cu.hmyperson

                inner join(

                                                Select

                                                                t.scode,

                                                                t.hmyperson ,

                                                                t2.hmy                

                                                from      tenant t                inner join property p on p.hmy=t.hproperty 

                                                                inner join trans t2 on t2.hperson=t.hmyperson 

                                                                inner join person per on per.hmy=t2.hperson and per.hmy=t.hmyperson                 

                                                Where

                                                                1 = 1

                                ) lease on lease.hmy=d.hchkorchg

                inner join commtenstatus ts on ts.istatus=t.istatus

Where tr.itype in ( 6, 7)  

                #conditions#

Group by tr.SUSERDEFINED1, tr.ITYPE,tr.SUSERDEFINED1,tr.SNOTES, p.hmy ,t.hunit ,t.hmyperson ,tr.hmy ,tr.sDateOccurred ,'Chk# ' + rtrim(ltrim(tr.uRef)) + ' paid out' + case when tr.hAccrualAcct <> t.hmyperson then rtrim(t.sCode) else '' end 

)A

Order by 1,2,3,4,6,5

//End Select

               

//Select S2

Select                                                                                                                   /*Added to Remove Duplicate Records*/
                phmy            phmy
                ,thunit         thunit
                ,thmyperson     thmyperson
                ,Sum(Current_Owed) Current_Owed
from
(              
Select
                p.hmy            phmy
                ,t.hunit         thunit
                ,t.hmyperson     thmyperson
                ,(CASE tr.iType
                                WHEN 7 THEN tr.sTotalAmount
                                ELSE -d.sAmount
                                END)     Current_Owed
From     property p
                inner join tenant t on (p.hmy = t.hproperty)
                inner join commtenstatus ts on ts.istatus=t.istatus
                inner join trans tr on (t.hMyPerson = tr.hPerson)
                inner join acct a on (tr.hOffsetAcct = a.hMy)
                left outer join detail d on (d.hinvorrec = tr.hmy and tr.itype = 6)
                left outer join trans trc on (d.hchkorchg = trc.hmy and trc.itype = 7 and trc.sDateOccurred <= dateadd(mm,1,'#endmonth#')- day('#endmonth#'))/*'#endmonth#')*/
Where tr.iType IN (6, 7)
        and isnull(t.bBillToCustomer,0) = 0                                         
                and   t.hProperty > 0
                and   tr.sDateOccurred <= dateadd(mm,1,'#endmonth#')- day('#endmonth#')
                /* and tr.void = case '#Revers#' when 'No' then 0 else tr.void end  */
                and isnull(tr.suserdefined2,' ') not in ( case '#Revers#' when 'No' then ':ReverseChg' else '!@#$%^&*()' end) 
                and tr.voider in(case tr.itype when 6 then 0 when 7 then tr.voider end , case tr.itype when 6 then case '#Revers#' when 'No' then 0 else -1 end when 7 then       tr.voider end)
                and (tr.void not in(case '#Revers#' when 'No' then -1  when 'Yes' then -1 else 0 end)   or tr.void not in(case '#Revers#' when 'No' then -1  when 'Yes' then 0 else 0 end)   )
                #conditions#

/*TO GET THE RECORDS FOR WHICH CHARGE IS APPLIED TO TENANT AND PAYMENT IS MADE BY CUSTOMER*REMOVED TO SHOW ONLY OPEN ITEMS AND NOT PAYMENTS/

FROM
                customer cu inner join  trans tr on cu.hmyperson = tr.hperson and tr.itype in ( 6, 7)  
                left outer join detail d on tr.hMy = d.hInvOrRec  
                left outer join acct a on isnull(d.hAcct, tr.hoffsetacct) = a.hmy  
                left outer join property p on  isnull(d.hProp, tr.hprop) = p.hMy  
                LEFT OUTER JOIN trans trc ON ( d.hChkOrChg = trc.hMy and trc.iType = 2 )  
                left outer join tenant t on t.hcustomer =cu.hmyperson
                inner join(
                                                Select
                                                                t.scode,
                                                                t.hmyperson ,
                                                                t2.hmy                
                                                from      tenant t                inner join property p on p.hmy=t.hproperty 
                                                                inner join trans t2 on t2.hperson=t.hmyperson 
                                                                inner join person per on per.hmy=t2.hperson and per.hmy=t.hmyperson                 
                                                Where
                                                                1 = 1
                                ) lease on lease.hmy=d.hchkorchg
                inner join commtenstatus ts on ts.istatus=t.istatus
Where tr.itype in ( 6, 7)  
                #conditions#
)aaa

Group by            
                phmy
                ,thunit
                ,thmyperson

//End Select      


//Columns

//Type  Name    Head1   Head2   Head3           Head4                   Show    Color   Formula Drill  Key   Width    Total

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      500,

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      500,

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      500,

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      500,

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      800,

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      500,

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      500,

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      500,

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      500,

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      500,

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      500,

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      500,

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      500,

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      500,

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      500,

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      500,

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      500,

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      500,

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      500,

T,      ,       ,      ,       ,      ,           Y,      ,       ,       ,        ,      500,

//End columns

//Filter

//Type, DataTyp,Name,                             Caption,  Key,                                              List ,                                          Val1, Val2, Mand, Multi, Title  Title

C,      T,      p.hMy,                          *Property,     ,                                                61 ,                               p.hMy = #p.hMy#,    ,    Y,     Y,     Y,

C,      T,      hPerson,                          Lease Id,     ,                                                 1 ,                       t.hMyPerson = #hPerson#,             ,     ,     Y,     Y,

0,      T,      namelike,          Lease Name Starts with,     ,                                                                                          , Upper(t.slastname) like Upper('#namelike#%'),                    ,     ,      ,     Y,

M,      T,      Status,                            Status,     , select status from commtenstatus order by iStatus ,                   ts.status in ( '#status#' ),             ,     ,     Y,     Y,

0,      T,      mindue,                     Min Amount Owed,     ,                                                                                           ,                                              ,               ,     ,      ,     Y,

R,      M,      begmonth:endmonth,            Month Range,     ,                                                                              ,                                                                               ,             ,    Y,      ,     Y,

0,      A,      begdate,                        Age As Of,     ,                                                                                          ,                                                                              ,             ,    Y,      ,     Y,

C,      T,      vendor,                    Company Vendor,     ,                                                 5 ,                         t.vendor = #vendor#,             ,    Y,     N,     Y,

L,      T,      Revers,                        Show Reversal?,     ,                                            No^Yes ,                                                                                               ,             ,    Y,      ,     Y,

0,      T,      hmessage,                       Message,     ,                                                                               ,                                                                                      ,             ,     ,      ,     Y,

L,      T,                    Units,                                   Show Units?,                                               ,       No^Yes,                                                         ,                     ,              Y,       ,     Y,

//end filter
