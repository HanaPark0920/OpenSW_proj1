#!/bin/bash

first_run=true

function menu_option_1() {

	#which id?
	read -p "Please enter 'movie id'(1~1682): " movie_id

	echo 

	if ! [[ $movie_id =~ ^[0-9]+$ ]] || ((movie_id < 1)) || ((movie_id > 1682)); then
        	echo "wrong id"
        	return
	fi

	awk -F'|' -v movie_id="$movie_id" '$1 == movie_id {print}' u.item

}

function menu_option_2() {

	#yes or no?
	read -p "Do you want to get the data of 'action' genre movies from 'u.item'?(y/n): " choice
	echo

	if [ "$choice" == "y" ]; then
		awk -F'|' '$7 == 1 {print $1, $2}' u.item | head -n 10
	fi
}

function menu_option_3() {

	read -p "Please enter the 'movie id' (1~1682): " movie_id
	
	echo

	average_rating=$(awk -v movie_id="$movie_id" -F'\t' '$2 == movie_id {sum += $3; count++} END {if (count > 0) { printf "%.5f\n", sum / count } else { print "No ratings available for this movie." }}' u.data)

	echo "average rating of $movie_id: $average_rating"
}


function menu_option_4() {
	read -p "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n): " choice
	
	echo

	if [ "$choice" == "y" ]; then
	
		sed -e 's/http.*)//g' u.item | head -n 10
	fi
}

function menu_option_5() {
	read -p "Do you want to get the data about users from 'u.user'?(y/n): " choice
	
	echo

	if [ "$choice" == "y" ]; then
		sed -n '1,10p' u.user | awk -F'|' '{ gender = ($3 == "M") ? "male" : "female"; printf "user %d is %d years old %s %s\n", $1, $2, gender, $4 }'
	fi
}

function menu_option_6() {
	read -p "Do you want to Modify the format of 'release date' in 'u.item'?(y/n): " choice

	echo 

	if [ "$choice" == "y" ]; then
		sed -e 's/Jan/01/g' -e 's/Feb/02/g' -e 's/Mar/03/g' -e 's/Apr/04/g' -e 's/May/05/g' -e 's/Jun/06/g' -e 's/Jul/07/g' -e 's/Aug/08/g' -e 's/Sep/09/g' -e 's/Oct/10/g' -e 's/Nov/11/g' -e 's/Dec/12/g' u.item | sed 's/\(..\)-\(..\)-\(....\)/\3\1\2/' | tail -n 10
	fi
}

function menu_option_7() {
	read -p "Please enter the 'user id' (1~943): " user_id
	
	echo 

	movie_ids=$(awk -v user_id="$user_id" '$1 == user_id { print $2 }' u.data | sort -n | uniq | tr '\n' '|')
    	echo "${movie_ids}"

	echo

	IFS='|' read -ra movie_array <<< "${movie_ids}"


	rated_movies=()
        for movie_id in "${movie_array[@]:0:10}"; do	
		movie_title=$(awk -F"|" -v id="$movie_id" '$1 == id { print $2 }' u.item)
        	rated_movies+=("$movie_id|$movie_title")
    	done

    	IFS=$'\n'
    	rated_movies_formatted="${rated_movies[*]}"
    	echo "$rated_movies_formatted"
}

function menu_option_8() {

		read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n): " choice

		if [ "$choice" != "y" ]; then
			return
		fi

		user_ids=$(awk -F"|" '$2 >= 20 && $2 <= 29 && $4 == "programmer" { print $1 }' u.user)

		for user_id in $user_ids; do
			ratings=$(awk -v user_id="$user_id" '$1 == user_id { print $3 }' u.data)

			if [ -n "$ratings" ]; then
				average_rating=$(echo "$ratings" | awk '{ sum+=$1; count++ } END { if (count > 0) printf "%.5f", sum/count }')
				echo "$user_id $average_rating"
			fi
			done | sort -n
}


while true; do

	if [ "$first_run" = true ]; then
		first_run=false
    		echo "--------------------------"
    		echo "User Name: 박하나"
    		echo "Student Number: 12223739"
    		echo "[ MENU ]"
    		echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
    		echo "2. Get the data of action genre movies from 'u.item'"
    		echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'"
		echo "4. Delete the 'IMDb URL' from 'u.item'"
    		echo "5. Get the data about users from 'u.user'"
    		echo "6. Modify the format of 'release date' in 'u.item'"
    		echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
    		echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
    		echo "9. Exit"
    		echo "--------------------------"
	fi
	
	echo

    	read -p "Enter your choice [1-9]: " choice
	
	echo

    	case $choice in

	    	1)
		    	menu_option_1
		    	;;
	    	2)
		    	menu_option_2
                    	;;
	    	3)
		    	menu_option_3
                    	;;
	    	4)
		    	menu_option_4
                    	;;
	    	5)
		    	menu_option_5
                    	;;
	    	6)
		    	menu_option_6
                    	;;
	    	7)
		    	menu_option_7
                    	;;
	    	8)
		    	menu_option_8
                    	;;
	    	9)
			echo "bye!"
		    	exit 0
		    	;;
	    	*)	
		    	echo "Invalid choice."
		    	;;
		esac
	done
	
