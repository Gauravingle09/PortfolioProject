select * from Portfolio_Project_2.dbo.DATA1
select * from Portfolio_Project_2.dbo.DATA2

--total no. of rows in each dataset
select count(*) from Portfolio_Project_2..DATA1
select count(*) from Portfolio_Project_2..DATA2

--dataset for Maharashtra,Gujarat
select * from Portfolio_Project_2..DATA1 where state in ('Maharashtra','Gujarat')

--total population
select sum(population) as Population from Portfolio_Project_2..DATA2

--average growth (overall)
select AVG(growth)*100 as Total_Average_Growth from Portfolio_Project_2..DATA1

--avg growth of state
select state,avg(growth)*100 Avg_Growth from Portfolio_Project_2..DATA1 group by State order by Avg_Growth desc 

--avg sex ratio in desc
select state, round(AVG(Sex_Ratio),0) as Avg_Sex_Ratio from Portfolio_Project_2..DATA1 group by State order by Avg_Sex_Ratio desc 

--avg literacy in desc
select state, round(AVG(Literacy),0) as Avg_Literacy from Portfolio_Project_2..DATA1 group by State
--having round(AVG(Literacy),0)<90 
order by Avg_Literacy desc 

--top 5 states with avg growth,sex ratio and literacy order by Avg_Growth desc
select top 5 state, avg(growth)*100 Avg_Growth, round(AVG(Sex_Ratio),0) as Avg_Sex_Ratio, round(AVG(Literacy),0) as Avg_Literacy
from Portfolio_Project_2..DATA1 group by State order by Avg_Growth desc

--bottom 5 states with avg growth,sex ratio and literacy order by Avg_Sex_Ratio asc
select top 5 state, avg(growth)*100 Avg_Growth, round(AVG(Sex_Ratio),0) as Avg_Sex_Ratio, round(AVG(Literacy),0) as Avg_Literacy
from Portfolio_Project_2..DATA1 group by State order by Avg_Sex_Ratio asc

--top & bottom 5 states in literacy rate
drop table if exists #top_states
create table #top_states
(
state nvarchar(255), topstate float
)
insert into #top_states
select state, round(AVG(Literacy),0) as Avg_Literacy from Portfolio_Project_2..DATA1 group by State order by Avg_Literacy desc 
select top 5 * from #top_states order by #top_states.topstate desc

drop table if exists #bottom_states
create table #bottom_states
(
state nvarchar(255), bottomstate float
)
insert into #bottom_states
select state, round(AVG(Literacy),0) as Avg_Literacy from Portfolio_Project_2..DATA1 group by State order by Avg_Literacy desc 
select top 5 * from #bottom_states order by #bottom_states.bottomstate asc

--union
select * from (
select top 5 * from #top_states order by #top_states.topstate desc) a
union 
select * from (
select top 5 * from #bottom_states order by #bottom_states.bottomstate asc) b

--states starting with letter m
select distinct state from Portfolio_Project_2..DATA1 where lower(state) like 'm%' or lower(state) like 'g%'
select distinct state from Portfolio_Project_2..DATA1 where lower(state) like 'm%' and lower(state) like '%a'

--joining data1 and data2
select a.district, a.state,a.sex_ratio,b.population from Portfolio_Project_2..DATA1 a inner join Portfolio_Project_2..DATA2 b on a.District=b.District

--calc total number of males and total number of females per state
---formula

---sex ratio = females/males......eq(1)
---population = females + males...eq(2)
---females = population - males...eq(3)
---eq(3) in eq(1)
---population - males = males * sex ratio
---population = males * (sex ratio + 1)
---males = population / (sex ratio + 1)
---females = population - population / (sex ratio + 1)
---        = population(1-1/(sex ratio + 1))
---        = (population * (sex ratio)) /  (sex ratio + 1)

select d.state, sum(d.males) as Total_Males,sum(d.females) as Total_Females from
(select c.district,c.state,round(c.population/(c.sex_ratio+1),0) as males, round((c.population*c.sex_ratio)/(c.Sex_Ratio+1),0) as females from
(select a.district, a.state,a.sex_ratio/1000 sex_ratio,b.population from Portfolio_Project_2..DATA1 a inner join Portfolio_Project_2..DATA2 b on a.District=b.District) c) d
group by d.State

--calc total literacy rate
--formula

--total literate people / population = literacy_ratio

select c.state,sum(literate_people) as Total_Literate_People,sum(illiterate_people) as Total_Illiterate_People from
(select d.district,d.state,round(d.literacy_ratio*d.population,0) as Literate_People, round((1-d.literacy_ratio)*d.population,0) as Illiterate_People from 
(select a.district, a.state,a.Literacy/100 as Literacy_ratio,b.population from Portfolio_Project_2..DATA1 a inner join Portfolio_Project_2..DATA2 b on a.District=b.District) d) c
group by c.state
order by Total_Literate_People desc

--population in previous census per state
--previous_census + growth * previous_census = population
--previous_census = population / (1 + growth) 

select e.state,sum(e.previous_census_population) as previous_census_population,sum(e.current_census_population) as current_census_population from
(select d.state,d.district,round(d.Population / (1 + growth),0) as Previous_Census_Population, population Current_Census_Population from
(select a.district, a.state,a.Growth as growth,b.population from Portfolio_Project_2..DATA1 a inner join Portfolio_Project_2..DATA2 b on a.District=b.District) d) e
group by e.state

--population in previous census in india
select sum(m.previous_census_population) as Previous_India_Census,sum(m.current_census_population) as Current_India_Census from
(select e.state,sum(e.previous_census_population) as previous_census_population,sum(e.current_census_population) as current_census_population from
(select d.state,d.district,round(d.Population / (1 + growth),0) as Previous_Census_Population, population Current_Census_Population from
(select a.district, a.state,a.Growth as growth,b.population from Portfolio_Project_2..DATA1 a inner join Portfolio_Project_2..DATA2 b on a.District=b.District) d) e
group by e.state) m


--population vs area
select g.Total_Area_km2/g.Previous_India_Census as Previous_Population_vs_area,g.Total_Area_km2/g.Current_India_Census as Current_Population_vs_area from
(select o.*,p.Total_Area_km2 from (

select '1' as keyy, n.* from
(select sum(m.previous_census_population) as Previous_India_Census,sum(m.current_census_population) as Current_India_Census from
(select e.state,sum(e.previous_census_population) as previous_census_population,sum(e.current_census_population) as current_census_population from
(select d.state,d.district,round(d.Population / (1 + growth),0) as Previous_Census_Population, population Current_Census_Population from
(select a.district, a.state,a.Growth as growth,b.population from Portfolio_Project_2..DATA1 a inner join Portfolio_Project_2..DATA2 b on a.District=b.District) d) e
group by e.state) m) n) o inner join (

select '1' as keyy, l.* from
(select sum(area_km2) as Total_Area_km2 from Portfolio_Project_2..DATA2) l) p on o.keyy = p.keyy) g

--window function
--output top 3 districts with highest literacy rate

select a.* from
(select district, state, literacy, rank() over(partition by state order by literacy desc) as Rankk from Portfolio_Project_2..DATA1) a
where a.rankk in (1,2,3) order by State 